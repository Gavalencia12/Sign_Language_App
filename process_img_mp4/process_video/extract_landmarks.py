import os, json, numpy as np, cv2, mediapipe as mp

# ==================== CONFIGURACIÓN ====================
DATA_DIR   = "/home/valencia/Documents/tesis/Sign_Language_App/process_img_mp4/process_video/videos"
OUT_DIR    = "/home/valencia/Documents/tesis/Sign_Language_App/process_img_mp4/process_video/landmarks_out"

# Extensiones soportadas
VIDEO_EXTS = (".mp4", ".mov", ".avi", ".mkv")
IMAGE_EXTS = (".jpg", ".jpeg", ".png", ".bmp")

NUM_FRAMES = 32           # Longitud de secuencia fija
WINDOWS_PER_VIDEO = 4     # Aumento de datos para videos (ventanas aleatorias)
# ========================================================

os.makedirs(OUT_DIR, exist_ok=True)
mp_holistic = mp.solutions.holistic

# Configuración de MediaPipe: Solo parte superior del cuerpo
POSE_UPPER = [0,1,2,3,4,7,8,11,12,13,14,15,16]
USE_UPPER_BODY_ONLY = True

def get_file_type(path):
    ext = os.path.splitext(path)[1].lower()
    if ext in VIDEO_EXTS: return "video"
    if ext in IMAGE_EXTS: return "image"
    return None

def walk_dataset(root):
    items=[]
    for sec in sorted(os.listdir(root)):
        sp = os.path.join(root, sec)
        if not os.path.isdir(sp): continue
        for label in sorted(os.listdir(sp)):
            lp = os.path.join(sp, label)
            if not os.path.isdir(lp): continue
            for fn in sorted(os.listdir(lp)):
                vp = os.path.join(lp, fn)
                if get_file_type(vp): items.append((vp,label))
    return items

def get_D():
    pose_len = (len(POSE_UPPER) if USE_UPPER_BODY_ONLY else 33)*3
    return pose_len + 21*3 + 21*3

def normalize(vec):
    """Normaliza las coordenadas respecto al tamaño del torso/brazos"""
    vec = vec.copy().reshape(-1,3)
    cx=cy=cz=0.0; scale=1.0
    try:
        if USE_UPPER_BODY_ONLY:
            iL=POSE_UPPER.index(11); iR=POSE_UPPER.index(12)
        else:
            iL,iR=11,12
        L,R = vec[iL],vec[iR]
        cx,cy,cz=(L+R)/2.0
        d=np.linalg.norm(R-L); scale=d if np.isfinite(d) and d>1e-4 else 1.0
    except Exception:
        pass
    vec[:,0]-=cx; vec[:,1]-=cy; vec[:,2]-=cz
    vec/=max(scale,1e-4)
    return vec.reshape(-1)

def lm_to_xyz(hand, n=21):
    if hand:
        out=[]
        for lm in hand.landmark:
            out += [lm.x,lm.y,lm.z]
        if len(out)<n*3: out += [0.0]*((n*3)-len(out))
        return out[:n*3]
    return [0.0]*(n*3)

def sample_indices(total, T, mode="uniform", jitter=True):
    if total<=0: return np.zeros((T,), int)
    if total<=T: return np.linspace(0, total-1, num=T).astype(int)
    if mode=="uniform":
        if jitter:
            start = np.random.randint(0, max(total-T,1)+1)
            end = start+T-1
            return np.linspace(start, end, num=T).astype(int)
        return np.linspace(0, total-1, num=T).astype(int)
    return np.linspace(0, total-1, num=T).astype(int)

# --- PROCESAMIENTO DE IMAGEN ESTÁTICA ---
def process_single_image(path, holo, T=NUM_FRAMES):
    img = cv2.imread(path)
    if img is None: return []
    rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    res = holo.process(rgb)
    
    # Extraer landmarks una sola vez
    if res.pose_landmarks:
        pose = res.pose_landmarks.landmark
        ids = POSE_UPPER if USE_UPPER_BODY_ONLY else range(33)
        pose_xyz=[]
        for j in ids:
            lm = pose[j]; pose_xyz += [lm.x,lm.y,lm.z]
    else:
        pose_xyz = [0.0]*((len(POSE_UPPER) if USE_UPPER_BODY_ONLY else 33)*3)

    left  = lm_to_xyz(res.left_hand_landmarks)
    right = lm_to_xyz(res.right_hand_landmarks)
    raw_vec = np.array(pose_xyz+left+right, np.float32)
    norm_vec = normalize(raw_vec)

    # REPETIR T veces + Ruido Gaussiano (Jitter) para simular "video"
    seq = []
    for _ in range(T):
        # Ruido muy pequeño para variar la pose estática
        noise = np.random.normal(0, 0.002, size=norm_vec.shape).astype(np.float32) 
        seq.append(norm_vec + noise)
    
    return [np.stack(seq, axis=0)]

# --- PROCESAMIENTO DE VIDEO ---
def process_video_frames(path, holo, T=NUM_FRAMES, windows=1):
    cap = cv2.VideoCapture(path)
    if not cap.isOpened(): return []
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if total<=0: 
        cap.release(); return []
        
    D = get_D(); out=[]
    for _ in range(max(1,windows)):
        idxs = sample_indices(total, T, mode="uniform", jitter=True)
        seq=[]
        for i in idxs:
            cap.set(cv2.CAP_PROP_POS_FRAMES, int(i))
            ok, fr = cap.read()
            if not ok or fr is None:
                seq.append(np.zeros((D,), np.float32)); continue
            rgb = cv2.cvtColor(fr, cv2.COLOR_BGR2RGB)
            res = holo.process(rgb)

            if res.pose_landmarks:
                pose = res.pose_landmarks.landmark
                ids = POSE_UPPER if USE_UPPER_BODY_ONLY else range(33)
                pose_xyz=[]
                for j in ids:
                    lm = pose[j]; pose_xyz += [lm.x,lm.y,lm.z]
            else:
                pose_xyz = [0.0]*((len(POSE_UPPER) if USE_UPPER_BODY_ONLY else 33)*3)
            left  = lm_to_xyz(res.left_hand_landmarks)
            right = lm_to_xyz(res.right_hand_landmarks)
            raw = np.array(pose_xyz+left+right, np.float32)
            seq.append(normalize(raw))
        out.append(np.stack(seq, axis=0))
    cap.release()
    return out

def main():
    items = walk_dataset(DATA_DIR)
    if not items:
        print(" No hay archivos en DATA_DIR."); return

    labels = sorted({lbl for _,lbl in items})
    label_map = {lbl:i for i,lbl in enumerate(labels)}
    
    # Guardar mapa de etiquetas
    with open(os.path.join(OUT_DIR, "label_map.json"), "w", encoding="utf-8") as f:
        json.dump(label_map, f, ensure_ascii=False, indent=2)

    D = get_D()
    print(f"Dataset encontrado: {len(items)} archivos.")
    print(f"Dimensiones: D={D} | Frames={NUM_FRAMES}")

    # MediaPipe Holistic
    with mp_holistic.Holistic(static_image_mode=False, model_complexity=1) as holo:
        for k,(vpath,lbl) in enumerate(items,1):
            try:
                ftype = get_file_type(vpath)
                seqs = []
                
                if ftype == "video":
                    # Extraer ventanas del video
                    seqs = process_video_frames(vpath, holo, NUM_FRAMES, WINDOWS_PER_VIDEO)
                elif ftype == "image":
                    # Convertir imagen a secuencia
                    seqs = process_single_image(vpath, holo, NUM_FRAMES)
                
                if not seqs: 
                    print(f"[SKIP] {vpath}"); continue
                
                y = label_map[lbl]
                base = os.path.splitext(os.path.basename(vpath))[0]
                
                # Guardar cada secuencia generada
                for w, X in enumerate(seqs):
                    if X.shape!=(NUM_FRAMES, D): continue
                    out_file = os.path.join(OUT_DIR, f"{base}_w{w}.npz")
                    np.savez_compressed(out_file, X=X.astype(np.float32), y=np.int32(y))
                    
            except Exception as e:
                print(f"[ERR] {vpath}: {e}")
                
            if k%20==0: print(f"  Procesados {k}/{len(items)}...")
            
    print(f" Extracción terminada, todos los datos guardados en: {OUT_DIR}")

if __name__=="__main__":
    main()