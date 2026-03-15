import os, glob, json, numpy as np, tensorflow as tf
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix, classification_report
from tensorflow.keras import layers, models

# ==================== CONFIGURACIÓN ====================
OUT_DIR     = "/home/valencia/Documents/tesis/Sign_Language_App/process_img_mp4/process_video/landmarks_out"
MODEL_PATH  = os.path.join(OUT_DIR, "../lsm_health_gru.h5")
TFLITE_PATH = os.path.join(OUT_DIR, "../lsm_health_gru_int8.tflite")
EPOCHS      = 100
BATCH_SIZE  = 32
VAL_SPLIT   = 0.3  # 30% para validación
SEED        = 42
# ========================================================

def list_npz():
    return sorted(glob.glob(os.path.join(OUT_DIR, "*.npz")))

def load_label_map():
    path = os.path.join(OUT_DIR, "label_map.json")
    if not os.path.exists(path):
        raise FileNotFoundError(f"No se encontró {path}. Ejecuta primero la extracción.")
    return json.load(open(path, "r", encoding="utf-8"))

def gen_npz(files):
    for f in files:
        d = np.load(f)
        yield d["X"].astype(np.float32), int(d["y"])

def make_ds(files, batch, shuffle=True):
    if not files:
        raise ValueError("La lista de archivos para el dataset está vacía.")
        
    # Leemos el primer archivo para obtener dimensiones
    X0, _ = next(gen_npz([files[0]]))
    T, D = X0.shape
    
    def g():
        for X, y in gen_npz(files):
            yield X, y
            
    sig = (tf.TensorSpec((T,D), tf.float32), tf.TensorSpec((), tf.int32))
    ds = tf.data.Dataset.from_generator(g, output_signature=sig)
    
    if shuffle:
        ds = ds.shuffle(buffer_size=min(len(files), 1000), seed=SEED, reshuffle_each_iteration=True)
    
    ds = ds.batch(batch).prefetch(tf.data.AUTOTUNE)
    return ds, (T, D)

# --- SPLIT POR GRUPOS (Para evitar fuga de datos) ---
def split_by_video_groups(files, val_split=VAL_SPLIT):
    """
    Agrupa los archivos .npz basándose en el nombre original del video
    para evitar que fragmentos del mismo video estén en train y val a la vez.
    """
    groups = {}
    for f in files:
        filename = os.path.basename(f)
        # Buscamos el separador de ventana "_w" (ej: video_01_w0.npz)
        if "_w" in filename:
            base = filename.rsplit("_w", 1)[0]
        else:
            base = filename 
        
        if base not in groups: groups[base] = []
        groups[base].append(f)
    
    group_keys = list(groups.keys())
    np.random.seed(SEED)
    np.random.shuffle(group_keys)
    
    cut = int(len(group_keys) * (1.0 - val_split))
    train_keys = group_keys[:cut]
    val_keys = group_keys[cut:]
    
    train_files = []
    for k in train_keys: train_files.extend(groups[k])
    
    val_files = []
    for k in val_keys: val_files.extend(groups[k])
    
    return train_files, val_files

def build_model(T, D, num_classes):
    inp = layers.Input(shape=(T, D)) 
    
    # Arquitectura GRU
    x = layers.GRU(128, dropout=0.1, return_sequences=True)(inp)
    x = layers.GRU(64,  dropout=0.1, return_sequences=False)(x)
    
    # Clasificador
    x = layers.Dense(64, activation='relu')(x)
    x = layers.Dropout(0.3)(x)
    out= layers.Dense(num_classes, activation='softmax')(x)

    model = models.Model(inp, out)
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])
    return model

# --- FUNCIONES DE GRAFICADO ---
def plot_history(history, out_dir):
    """Genera curvas de Accuracy y Loss"""
    if 'accuracy' not in history.history:
        return

    acc = history.history['accuracy']
    val_acc = history.history['val_accuracy']
    loss = history.history['loss']
    val_loss = history.history['val_loss']
    epochs_range = range(len(acc))

    plt.figure(figsize=(12, 5))
    
    # 1. Accuracy
    plt.subplot(1, 2, 1)
    plt.plot(epochs_range, acc, label='Entrenamiento')
    plt.plot(epochs_range, val_acc, label='Validación')
    plt.legend(loc='lower right')
    plt.title('Exactitud (Accuracy)')
    plt.grid(True)

    # 2. Loss
    plt.subplot(1, 2, 2)
    plt.plot(epochs_range, loss, label='Entrenamiento')
    plt.plot(epochs_range, val_loss, label='Validación')
    plt.legend(loc='upper right')
    plt.title('Pérdida (Loss)')
    plt.grid(True)

    save_path = os.path.join(out_dir, "grafica_aprendizaje.png")
    plt.savefig(save_path)
    print(f" Gráficas guardadas en: {save_path}")
    plt.close()

def plot_confusion_matrix(model, val_ds, label_map, out_dir):
    """Genera Matriz de Confusión"""
    print(" Generando matriz de confusión...")
    y_true = []
    y_pred = []

    for X_batch, y_batch in val_ds:
        preds = model.predict(X_batch, verbose=0)
        y_true.extend(y_batch.numpy())
        y_pred.extend(np.argmax(preds, axis=1))

    # Ordenar clases por índice
    idx_to_class = {v: k for k, v in label_map.items()}
    class_names = [idx_to_class[i] for i in range(len(idx_to_class))]

    # Matriz
    cm = confusion_matrix(y_true, y_pred)
    
    plt.figure(figsize=(12, 10))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                xticklabels=class_names, yticklabels=class_names)
    plt.xlabel('Predicción')
    plt.ylabel('Real')
    plt.title('Matriz de Confusión')
    plt.xticks(rotation=45, ha='right')
    
    cm_path = os.path.join(out_dir, "matriz_confusion.png")
    plt.savefig(cm_path, bbox_inches='tight')
    print(f" Matriz guardada en: {cm_path}")
    plt.close()

    # Reporte
    report = classification_report(y_true, y_pred, target_names=class_names)
    rep_path = os.path.join(out_dir, "reporte_metricas.txt")
    with open(rep_path, "w") as f:
        f.write(report)
    print(f" Reporte guardado en: {rep_path}")

def main():
    files = list_npz()
    if not files:
        print(" No hay .npz en OUT_DIR."); return
    
    label_map = load_label_map()
    num_classes = len(label_map)
    
    # Split
    train_files, val_files = split_by_video_groups(files, VAL_SPLIT)
    print(f"Total: {len(files)} | Train: {len(train_files)} | Val: {len(val_files)}")
    
    if len(train_files) == 0 or len(val_files) == 0:
        print("Error: Datos insuficientes."); return

    # Datasets
    train_ds, (T,D) = make_ds(train_files, BATCH_SIZE, shuffle=True)
    val_ds, _       = make_ds(val_files,   BATCH_SIZE, shuffle=False)

    model = build_model(T, D, num_classes)
    
    cbs = [
        tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=5, min_lr=1e-6, verbose=1),
        tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=10, restore_best_weights=True, verbose=1),
        tf.keras.callbacks.ModelCheckpoint(MODEL_PATH, save_best_only=True, monitor="val_accuracy")
    ]

    print(" Iniciando entrenamiento...")
    history = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=cbs, verbose=1)

    print(f" Mejor modelo guardado en: {MODEL_PATH}")

    # --- AQUI ESTABA EL ERROR: AHORA SÍ LLAMAMOS A LAS FUNCIONES ---
    try:
        plot_history(history, OUT_DIR)
        
        # Cargar el mejor modelo para la matriz (no el último)
        best_model_for_cm = tf.keras.models.load_model(MODEL_PATH)
        plot_confusion_matrix(best_model_for_cm, val_ds, label_map, OUT_DIR)
    except Exception as e:
        print(f" Error al graficar: {e}")
    # -------------------------------------------------------------

    # --- TFLITE CON SOPORTE PARA GRU (SELECT TF OPS) ---
    print(" Convirtiendo a TFLite...")
    best_model = tf.keras.models.load_model(MODEL_PATH)
    converter = tf.lite.TFLiteConverter.from_keras_model(best_model)
    
    # Habilitar operaciones de TensorFlow estándar (Flex Delegates)
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS, # Ops nativas Lite
        tf.lite.OpsSet.SELECT_TF_OPS    # Ops complejas de TF
    ]
    
    # Deshabilitar experimental lower para evitar error de TensorList
    converter._experimental_lower_tensor_list_ops = False
    
    # Optimización básica
    converter.optimizations = [tf.lite.Optimize.DEFAULT]

    tfl = converter.convert()
    
    with open(TFLITE_PATH, "wb") as f:
        f.write(tfl)
    
    print(f" TFLite guardado: {TFLITE_PATH}")

if __name__=="__main__":
    main()