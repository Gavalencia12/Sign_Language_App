# realtime_landmark_infer_h5.py
import argparse, json, os, sys
import numpy as np
import cv2
import mediapipe as mp
from tensorflow.keras.models import load_model

# --- RUTAS ---
# Intenta usar rutas relativas si es posible, o mantén las absolutas si trabajas localmente
BASE_DIR = "/home/valencia/Documents/tesis/Sign_Language_App/process_img_mp4/process_video"
DEFAULT_MODEL_PATH  = os.path.join(BASE_DIR, "lsm_health_gru.h5")
DEFAULT_LABELS_PATH = os.path.join(BASE_DIR, "landmarks_out/label_map.json")

# ---------- Parámetros ----------
DEFAULT_T = 32
POSE_UPPER = [0,1,2,3,4,7,8,11,12,13,14,15,16]
USE_UPPER_BODY_ONLY = True

MIN_HAND_FRAMES_START = 5   # Aumenté un poco para evitar falsos positivos rápidos
END_AFTER_MISSING = 10      # Más tolerancia si la mano desaparece brevemente
MIN_FRAMES_TO_EVAL = 16     # Mínimo de frames para intentar predecir
CONF_THRESHOLD = 0.70       # Subí el umbral al 70% para estar más seguros
# --------------------------------

mp_holistic = mp.solutions.holistic
mp_draw = mp.solutions.drawing_utils
mp_styles = mp.solutions.drawing_styles

def load_labels(path):
    if not os.path.exists(path):
        print(f"[ERROR] No encuentro el archivo de etiquetas: {path}")
        sys.exit(1)
    m = json.load(open(path, "r", encoding="utf-8"))
    out = {}
    for k,v in m.items():
        # json guarda keys como strings, aseguramos mapeo int->string
        out[int(v)] = k 
    return out

#  
# Útil para entender qué puntos (0-32) estamos extrayendo
def get_D():
    pose_len = (len(POSE_UPPER) if USE_UPPER_BODY_ONLY else 33)*3
    return pose_len + 21*3 + 21*3

def lm_to_xyz(hand, n=21):
    if hand:
        pts=[]
        for lm in hand.landmark: pts += [lm.x,lm.y,lm.z]
        # Padding si faltan puntos (raro en manos completas, pero por seguridad)
        if len(pts)<n*3: pts += [0.0]*((n*3)-len(pts))
        return pts[:n*3]
    return [0.0]*(n*3)

def normalize(vec):
    """ Debe ser IDENTICA a la usada en entrenamiento """
    v = vec.copy().reshape(-1,3)
    cx=cy=cz=0.0; scale=1.0
    try:
        if USE_UPPER_BODY_ONLY:
            # Indices relativos en el array reducido
            iL=POSE_UPPER.index(11); iR=POSE_UPPER.index(12)
        else:
            iL,iR=11,12
        L,R=v[iL],v[iR]
        cx,cy,cz=(L+R)/2.0
        d=np.linalg.norm(R-L)
        scale = d if np.isfinite(d) and d>1e-4 else 1.0
    except Exception:
        pass
    v[:,0]-=cx; v[:,1]-=cy; v[:,2]-=cz
    v/=max(scale,1e-4)
    return v.reshape(-1).astype(np.float32)

def features_from_frame(results):
    # Pose
    if results.pose_landmarks:
        pose = results.pose_landmarks.landmark
        ids = POSE_UPPER if USE_UPPER_BODY_ONLY else range(33)
        pose_xyz=[]
        for j in ids:
            lm = pose[j]; pose_xyz += [lm.x,lm.y,lm.z]
    else:
        pose_xyz=[0.0]*((len(POSE_UPPER) if USE_UPPER_BODY_ONLY else 33)*3)
    
    # Manos
    left  = lm_to_xyz(results.left_hand_landmarks, 21)
    right = lm_to_xyz(results.right_hand_landmarks,21)
    
    raw = np.array(pose_xyz+left+right, dtype=np.float32)
    return normalize(raw)

def resample_sequence(seq, T):
    seq = np.asarray(seq, dtype=np.float32)
    L, D = seq.shape
    if L == T: return seq
    if L < T:
        # Si es muy corto, podemos hacer padding o interpolación
        # Aquí hacemos interpolación simple (resample)
        idxs = np.linspace(0, L-1, num=T)
        # Interpolación lineal manual rápida
        out = np.zeros((T, D), dtype=np.float32)
        for d_i in range(D):
            out[:, d_i] = np.interp(idxs, np.arange(L), seq[:, d_i])
        return out
    else:
        # Si es más largo, tomamos índices equidistantes
        idxs = np.linspace(0, L-1, num=T).astype(int)
        return seq[idxs]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default=DEFAULT_MODEL_PATH)
    ap.add_argument("--labels", default=DEFAULT_LABELS_PATH)
    ap.add_argument("--video", default=None) # Si es None usa webcam 0
    args = ap.parse_args()

    if not os.path.exists(args.model):
        print(f"No encuentro el modelo: {args.model}")
        return

    labels_inv = load_labels(args.labels) # {0: 'Hola', 1: 'Adios'}
    T = DEFAULT_T
    
    print(f"Cargando modelo Keras: {args.model}")
    model = load_model(args.model)
    print("Modelo cargado.")

    cap = cv2.VideoCapture(args.video if args.video else 0)
    
    state = "IDLE" # IDLE -> RECORDING
    recorded = []
    frames_no_hand = 0
    frames_with_hand = 0
    
    pred_text = "Esperando..."
    pred_conf = 0.0

    with mp_holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5) as holo:
        while True:
            ok, frame = cap.read()
            if not ok: break

            # Espejo si es webcam
            if args.video is None:
                frame = cv2.flip(frame, 1)

            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = holo.process(rgb)

            # Lógica de detección de manos (si hay al menos una mano visible)
            has_hands = (results.left_hand_landmarks or results.right_hand_landmarks)

            # Dibujar Landmarks
            mp_draw.draw_landmarks(frame, results.pose_landmarks, mp_holistic.POSE_CONNECTIONS)
            mp_draw.draw_landmarks(frame, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS)
            mp_draw.draw_landmarks(frame, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS)

            # Máquina de estados
            if state == "IDLE":
                if has_hands:
                    frames_with_hand += 1
                    if frames_with_hand >= MIN_HAND_FRAMES_START:
                        state = "RECORDING"
                        recorded = []
                        frames_no_hand = 0
                        print(">>> Iniciando grabación de seña")
                else:
                    frames_with_hand = 0
            
            elif state == "RECORDING":
                if has_hands:
                    frames_no_hand = 0
                    feat = features_from_frame(results)
                    recorded.append(feat)
                else:
                    frames_no_hand += 1
                    # Si no detectamos manos por N frames, terminamos la seña
                    if frames_no_hand >= END_AFTER_MISSING:
                        print(f"<<< Fin grabación. Frames capturados: {len(recorded)}")
                        
                        if len(recorded) >= MIN_FRAMES_TO_EVAL:
                            # PROCESAR
                            inp = resample_sequence(recorded, T) # (32, D)
                            inp = np.expand_dims(inp, axis=0)    # (1, 32, D)
                            
                            probs = model.predict(inp, verbose=0)[0]
                            idx = np.argmax(probs)
                            conf = probs[idx]
                            
                            label_str = labels_inv.get(idx, "Desc")
                            
                            if conf >= CONF_THRESHOLD:
                                pred_text = f"{label_str}"
                                pred_conf = conf
                                color_box = (0, 255, 0) # Verde
                            else:
                                pred_text = f"{label_str} (?)"
                                pred_conf = conf
                                color_box = (0, 165, 255) # Naranja (duda)
                            
                            print(f"Predicción: {label_str} ({conf:.2%})")
                        else:
                            print("Seña muy corta, ignorada.")
                            pred_text = "..."
                            color_box = (100, 100, 100)

                        # Reset
                        state = "IDLE"
                        recorded = []
                        frames_with_hand = 0

            # --- UI ---
            # Barra de estado
            if state == "RECORDING":
                cv2.circle(frame, (30, 30), 10, (0, 0, 255), -1) # Punto rojo grabando
                cv2.putText(frame, "REC", (50, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
            else:
                cv2.putText(frame, "LISTO", (50, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (200, 200, 200), 2)

            # Caja de predicción
            cv2.rectangle(frame, (0, frame.shape[0]-60), (frame.shape[0], frame.shape[0]), (0,0,0), -1)
            cv2.putText(frame, f"{pred_text} ({pred_conf:.0%})", 
                        (20, frame.shape[0]-20), 
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)

            cv2.imshow("Inferencia LSM", frame)
            if cv2.waitKey(1) & 0xFF == 27: # ESC para salir
                break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()