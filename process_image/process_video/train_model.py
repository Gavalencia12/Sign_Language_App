# extract_landmarks.py
import os, json, numpy as np, cv2, mediapipe as mp

# === AJUSTA AQUÍ ===
DATA_DIR   = "/home/valencia/Documents/Tesis/Sign_Language_App/process_image/process_video/videos"
OUT_DIR    = "/home/valencia/Documents/Tesis/Sign_Language_App/process_image/process_video/landmarks_out"
VIDEO_EXTS = (".mp4", ".mov")
NUM_FRAMES = 32           # frames por muestra (fijos)
WINDOWS_PER_VIDEO = 4     # cuántas ventanas distintas por video (data aug temporal)
# ====================

os.makedirs(OUT_DIR, exist_ok=True)
mp_holistic = mp.solutions.holistic
POSE_UPPER = [0,1,2,3,4,7,8,11,12,13,14,15,16]
USE_UPPER_BODY_ONLY = True

def is_video(p): return os.path.splitext(p)[1].lower() in VIDEO_EXTS

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
                if is_video(vp): items.append((vp,label))
    return items

def get_D():
    pose_len = (len(POSE_UPPER) if USE_UPPER_BODY_ONLY else 33)*3
    return pose_len + 21*3 + 21*3

def normalize(vec):
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
    if total<=T:
        return np.linspace(0, total-1, num=T).astype(int)
    if mode=="uniform":
        if jitter:
            # ventana aleatoria de longitud T dentro de total
            start = np.random.randint(0, max(total-T,1)+1)
            end = start+T-1
            return np.linspace(start, end, num=T).astype(int)
        else:
            return np.linspace(0, total-1, num=T).astype(int)
    return np.linspace(0, total-1, num=T).astype(int)

def extract_video(path, T=NUM_FRAMES, windows=1):
    cap = cv2.VideoCapture(path)
    if not cap.isOpened(): return []
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if total<=0:
        frames=[]
        while True:
            ret,f=cap.read()
            if not ret or f is None: break
            frames.append(f)
        total=len(frames); cap.release(); cap=None
        # reabrimos si usamos cache
        cap = cv2.VideoCapture(path)
    D = get_D(); out=[]
    with mp_holistic.Holistic(static_image_mode=True, model_complexity=1) as holo:
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
            out.append(np.stack(seq, axis=0))  # (T,D)
    cap.release()
    return out

def main():
    items = walk_dataset(DATA_DIR)
    if not items:
        print("No hay videos. Verifica DATA_DIR"); return

    labels = sorted({lbl for _,lbl in items})
    label_map = {lbl:i for i,lbl in enumerate(labels)}
    with open(os.path.join(OUT_DIR, "label_map.json"), "w", encoding="utf-8") as f:
        json.dump(label_map, f, ensure_ascii=False, indent=2)

    D = get_D()
    print(f"Feature dim D={D} | NUM_FRAMES={NUM_FRAMES} | WINDOWS_PER_VIDEO={WINDOWS_PER_VIDEO}")
    os.makedirs(OUT_DIR, exist_ok=True)

    for k,(vpath,lbl) in enumerate(items,1):
        try:
            seqs = extract_video(vpath, NUM_FRAMES, WINDOWS_PER_VIDEO)
            if not seqs: 
                print("[SKIP]", vpath); continue
            y = label_map[lbl]
            base = os.path.splitext(os.path.basename(vpath))[0]
            for w, X in enumerate(seqs):
                if X.shape!=(NUM_FRAMES, D): 
                    print("[SKIP shape]", vpath); continue
                out_file = os.path.join(OUT_DIR, f"{base}_w{w}.npz")
                np.savez_compressed(out_file, X=X.astype(np.float32), y=np.int32(y))
        except Exception as e:
            print("[ERR]", vpath, e)
        if k%20==0: print(f"  Procesados {k}/{len(items)}")
    print("✅ Terminado. Archivos en:", OUT_DIR)

if __name__=="__main__":
    main()
