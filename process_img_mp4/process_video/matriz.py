import os, glob, json, numpy as np, tensorflow as tf
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix, classification_report
import pandas as pd

# ==================== CONFIGURACIÓN ====================
OUT_DIR     = "/home/valencia/Documents/tesis/Sign_Language_App/process_img_mp4/process_video/landmarks_out"
MODEL_PATH  = os.path.join(OUT_DIR, "../lsm_health_gru.h5")
BATCH_SIZE  = 32
VAL_SPLIT   = 0.3
SEED        = 42
# ========================================================

def list_npz():
    return sorted(glob.glob(os.path.join(OUT_DIR, "*.npz")))

def load_label_map():
    path = os.path.join(OUT_DIR, "label_map.json")
    if not os.path.exists(path):
        raise FileNotFoundError(f"No se encontró el mapa de etiquetas en: {path}")
    return json.load(open(path, "r", encoding="utf-8"))

def gen_npz(files):
    for f in files:
        d = np.load(f)
        yield d["X"].astype(np.float32), int(d["y"])

def make_ds(files, batch):
    # Solo se necesita leer una para sacar dimensiones, aunque cargaremos el modelo guardado
    X0,y0 = next(gen_npz([files[0]]))
    T,D = X0.shape
    
    def g():
        for X,y in gen_npz(files):
            yield X,y
            
    sig = (tf.TensorSpec((T,D), tf.float32), tf.TensorSpec((), tf.int32))
    ds = tf.data.Dataset.from_generator(g, output_signature=sig)
    ds = ds.batch(batch).prefetch(tf.data.AUTOTUNE)
    return ds

def split(files, val=VAL_SPLIT):
    idx = np.arange(len(files))
    np.random.seed(SEED); np.random.shuffle(idx)
    cut = int(len(files)*(1.0-val))
    return [files[i] for i in idx[:cut]], [files[i] for i in idx[cut:]]

def plot_confusion_matrix_hd(model, val_ds, label_map, out_dir):
    print(" Generando predicciones (esto puede tardar un poco)...")
    y_true = []
    y_pred = []

    for X_batch, y_batch in val_ds:
        preds = model.predict(X_batch, verbose=0)
        y_true.extend(y_batch.numpy())
        y_pred.extend(np.argmax(preds, axis=1))

    # Nombres de clases ordenados por su índice (0, 1, 2...)
    inv_map = {v: k for k, v in label_map.items()}
    class_names = [inv_map[i] for i in range(len(inv_map))]

    cm = confusion_matrix(y_true, y_pred)
    
    plt.figure(figsize=(40, 40)) 
    
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', cbar=False,
                xticklabels=class_names, yticklabels=class_names,
                annot_kws={"size": 10}) # Tamaño de numero dentro del cuadro
    
    plt.xlabel('Predicción', fontsize=24)
    plt.ylabel('Real', fontsize=24)
    plt.title('Matriz de Confusión - Validación (HD)', fontsize=30)
    plt.xticks(fontsize=12, rotation=90) # Rotar texto eje X
    plt.yticks(fontsize=12, rotation=0)
    
    save_path = os.path.join(out_dir, "matriz_confusion_HD.png")
    plt.tight_layout()
    plt.savefig(save_path)
    print(f" Imagen HD guardada en: {save_path}")
    plt.close()

    # 2. GUARDAR EN EXCEL (CSV) PARA ANÁLISIS DETALLADO
    # Esto te permite ver exactamente qué palabra se confunde con cuál
    df_cm = pd.DataFrame(cm, index=class_names, columns=class_names)
    csv_path = os.path.join(out_dir, "matriz_confusion_datos.csv")
    df_cm.to_csv(csv_path)
    print(f" Excel de errores guardado en: {csv_path}")

def main():
    files = list_npz()
    if not files: print(" No hay archivos .npz"); return
    
    # Cargar mapa
    label_map = load_label_map()
    
    # Separar datos (Usamos solo Validación)
    _, val_files = split(files, VAL_SPLIT)
    print(f" Cargando {len(val_files)} archivos de validación...")
    
    val_ds = make_ds(val_files, BATCH_SIZE)

    # Cargar modelo PRE-ENTRENADO
    if not os.path.exists(MODEL_PATH):
        print(f" No encuentro el modelo en {MODEL_PATH}")
        return
        
    print(f" Cargando modelo: {MODEL_PATH}")
    model = tf.keras.models.load_model(MODEL_PATH)

    # Graficar
    plot_confusion_matrix_hd(model, val_ds, label_map, OUT_DIR)

if __name__=="__main__":
    main()