# realtime_landmark_infer_h5.py
import argparse, json, os
import numpy as np
import cv2
import mediapipe as mp
from tensorflow.keras.models import load_model

# ====== RUTAS POR DEFECTO (ajustadas a tu PC) ======
DEFAULT_MODEL_PATH  = "/home/valencia/Documents/Tesis/Sign_Language_App/process_image/process_video/lsm_health_gru.h5"
DEFAULT_LABELS_PATH = "/home/valencia/Documents/Tesis/Sign_Language_App/process_image/process_video/landmarks_out/label_map.json"
# ===================================================

# ---------- Parámetros ----------
DEFAULT_T = 32
POSE_UPPER = [0,1,2,3,4,7,8,11,12,13,14,15,16]
USE_UPPER_BODY_ONLY = True

MIN_HAND_FRAMES_START = 3   # para empezar a grabar
END_AFTER_MISSING = 8       # cortar después de N frames sin manos
MIN_FRAMES_TO_EVAL = 12     # mínimo para evaluar
CONF_THRESHOLD = 0.50       # no reportar si la confianza Top-1 < 50%
SAVE_SEGMENTS = False       # True para guardar cada segmento como .npz
SEGMENTS_DIR = "/home/valencia/Documents/Tesis/Sign_Language_App/process_image/process_video/landmarks_out"
# --------------------------------

mp_holistic = mp.solutions.holistic
mp_draw = mp.solutions.drawing_utils
mp_styles = mp.solutions.drawing_styles

def load_labels(path):
    m = json.load(open(path, "r", encoding="utf-8"))
    # soporta idx->clase o clase->idx
    if isinstance(list(m.keys())[0], str) and isinstance(list(m.values())[0], int):
        inv = [None]*len(m)
        for k,v in m.items(): inv[v]=k
        return inv
    out = [None]*len(m)
    for k,v in m.items(): out[int(k)] = v
    return out

def get_D():
    pose_len = (len(POSE_UPPER) if USE_UPPER_BODY_ONLY else 33)*3
    return pose_len + 21*3 + 21*3

def lm_to_xyz(hand, n=21):
    if hand:
        pts=[]
        for lm in hand.landmark: pts += [lm.x,lm.y,lm.z]
        if len(pts)<n*3: pts += [0.0]*((n*3)-len(pts))
        return pts[:n*3]
    return [0.0]*(n*3)

def normalize(vec):
    v = vec.copy().reshape(-1,3)
    cx=cy=cz=0.0; scale=1.0
    try:
        if USE_UPPER_BODY_ONLY:
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
    if results.pose_landmarks:
        pose = results.pose_landmarks.landmark
        ids = POSE_UPPER if USE_UPPER_BODY_ONLY else range(33)
        pose_xyz=[]
        for j in ids:
            lm = pose[j]; pose_xyz += [lm.x,lm.y,lm.z]
    else:
        pose_xyz=[0.0]*((len(POSE_UPPER) if USE_UPPER_BODY_ONLY else 33)*3)
    left  = lm_to_xyz(results.left_hand_landmarks, 21)
    right = lm_to_xyz(results.right_hand_landmarks,21)
    raw = np.array(pose_xyz+left+right, dtype=np.float32)
    return normalize(raw)

def resample_sequence(seq, T):
    seq = np.asarray(seq, dtype=np.float32)
    L, D = seq.shape
    if L == T: return seq
    if L <= 1: return np.zeros((T, D), dtype=np.float32)
    idxs = np.linspace(0, L-1, num=T).astype(int)
    return seq[idxs]

def topk(probs, labels, k=3):
    idxs = np.argsort(-probs)[:k]
    return [(labels[i], float(probs[i])) for i in idxs]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default=DEFAULT_MODEL_PATH, help="Ruta al .h5 (Keras)")
    ap.add_argument("--labels", default=DEFAULT_LABELS_PATH, help="Ruta a label_map.json")
    ap.add_argument("--num_frames", type=int, default=DEFAULT_T)
    ap.add_argument("--video", type=str, default=None, help="Ruta a video (opcional). Por defecto webcam.")
    args = ap.parse_args()

    labels = load_labels(args.labels)
    T = args.num_frames
    D = get_D()

    # Cargar modelo Keras (.h5)
    print(f"Cargando modelo: {args.model}")
    model = load_model(args.model)

    if SAVE_SEGMENTS:
        os.makedirs(SEGMENTS_DIR, exist_ok=True)

    cap = cv2.VideoCapture(args.video if args.video else 0)
    if not cap.isOpened():
        print("[ERROR] No pude abrir cámara / video")
        return

    state = "IDLE"
    recorded = []
    hands_present_streak = 0
    hands_absent_streak = 0
    last_result_txt = "—"

    with mp_holistic.Holistic(static_image_mode=False,
                              model_complexity=1,
                              enable_segmentation=False,
                              refine_face_landmarks=False) as holo:
        while True:
            ok, frame = cap.read()
            if not ok or frame is None: break

            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            res = holo.process(rgb)

            hands_present = (res.left_hand_landmarks is not None) or (res.right_hand_landmarks is not None)

            # Dibujo
            mp_draw.draw_landmarks(frame, res.pose_landmarks, mp_holistic.POSE_CONNECTIONS,
                                   landmark_drawing_spec=mp_styles.get_default_pose_landmarks_style())
            mp_draw.draw_landmarks(frame, res.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS)
            mp_draw.draw_landmarks(frame, res.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS)

            if state == "IDLE":
                hands_present_streak = hands_present_streak + 1 if hands_present else 0
                if hands_present_streak >= MIN_HAND_FRAMES_START:
                    state = "RECORDING"
                    recorded = []
                    hands_absent_streak = 0
            else:
                feat = features_from_frame(res)
                recorded.append(feat)
                hands_absent_streak = 0 if hands_present else hands_absent_streak + 1

                if hands_absent_streak >= END_AFTER_MISSING:
                    seq = np.asarray(recorded, dtype=np.float32)
                    if len(seq) >= MIN_FRAMES_TO_EVAL:
                        X = resample_sequence(seq, T)       # (T,D)
                        X = X[np.newaxis, ...]              # (1,T,D)
                        probs = model.predict(X, verbose=0)[0]  # (num_classes,)

                        # Top-3
                        k3 = topk(probs, labels, k=3)
                        top1_label, top1_p = k3[0]

                        if SAVE_SEGMENTS:
                            seg_path = os.path.join(SEGMENTS_DIR, f"seg_{int(cv2.getTickCount())}.npz")
                            np.savez_compressed(seg_path, X=X[0].astype(np.float32), probs=probs.astype(np.float32))
                            print(f"💾 Segmento guardado: {seg_path}")

                        if top1_p >= CONF_THRESHOLD:
                            last_result_txt = f"Pred: {top1_label} ({top1_p*100:.1f}%)  | Top-3: " + \
                                              ", ".join([f"{lbl}:{p*100:.0f}%" for lbl,p in k3])
                        else:
                            last_result_txt = f"Conf baja ({top1_p*100:.1f}%). No decidido. Top-3: " + \
                                              ", ".join([f"{lbl}:{p*100:.0f}%" for lbl,p in k3])

                        print(last_result_txt)
                    else:
                        last_result_txt = "Segmento muy corto, descartado."
                        print(last_result_txt)

                    state = "IDLE"
                    recorded = []
                    hands_present_streak = 0
                    hands_absent_streak = 0

            # UI
            h,w = frame.shape[:2]
            bar_color = (0, 180, 0) if state=="RECORDING" else (60,60,60)
            cv2.rectangle(frame, (0,0), (1000,28), bar_color, -1)
            cv2.namedWindow("LSM - Segmentador por manos (.h5)  [q para salir]", cv2.WINDOW_NORMAL)
            cv2.resizeWindow("LSM - Segmentador por manos (.h5)  [q para salir]", 1000, 700)
            cv2.putText(frame, f"Estado: {state} | {last_result_txt}",
                        (10,20), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (255,255,255), 2, cv2.LINE_AA)
            cv2.imshow("LSM - Segmentador por manos (.h5)  [q para salir]", frame)

            if cv2.waitKey(1) & 0xFF == ord('q'): break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
