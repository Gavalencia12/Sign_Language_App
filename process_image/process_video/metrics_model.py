# train_landmarks_gru.py
import os, glob, json, numpy as np, tensorflow as tf
from tensorflow.keras import layers, models

# === AJUSTA AQUÍ ===
OUT_DIR     = "/home/valencia/Documents/Tesis/Sign_Language_App/process_image/process_video/landmarks_out"
MODEL_PATH  = os.path.join(OUT_DIR, "../lsm_health_gru.h5")
TFLITE_PATH = os.path.join(OUT_DIR, "../lsm_health_gru_int8.tflite")
EPOCHS      = 40
BATCH_SIZE  = 32
VAL_SPLIT   = 0.2
SEED        = 42
# ====================

def list_npz():
    return sorted(glob.glob(os.path.join(OUT_DIR, "*.npz")))

def load_label_map():
    return json.load(open(os.path.join(OUT_DIR, "label_map.json"), "r", encoding="utf-8"))

def gen_npz(files):
    for f in files:
        d = np.load(f)
        yield d["X"].astype(np.float32), int(d["y"])

def make_ds(files, batch, shuffle=True):
    X0,y0 = next(gen_npz([files[0]]))
    T,D = X0.shape
    def g():
        for X,y in gen_npz(files):
            yield X,y
    sig = (tf.TensorSpec((T,D), tf.float32), tf.TensorSpec((), tf.int32))
    ds = tf.data.Dataset.from_generator(g, output_signature=sig)
    if shuffle: ds = ds.shuffle(buffer_size=len(files), seed=SEED, reshuffle_each_iteration=True)
    ds = ds.batch(batch).prefetch(tf.data.AUTOTUNE)
    return ds,(T,D)

def split(files, val=VAL_SPLIT):
    idx = np.arange(len(files))
    np.random.seed(SEED); np.random.shuffle(idx)
    cut = int(len(files)*(1.0-val))
    return [files[i] for i in idx[:cut]], [files[i] for i in idx[cut:]]

def build_model(T, D, num_classes):
    inp = layers.Input(shape=(T, D))  # T fijo, D fijo

    # GRU desenrolladas (evita TensorList/TensorArray)
    x = layers.GRU(128, dropout=0.2, return_sequences=True, unroll=True)(inp)
    x = layers.GRU(64,  dropout=0.2, return_sequences=False, unroll=True)(x)

    x = layers.Dense(128, activation='relu')(x)
    x = layers.Dropout(0.3)(x)
    out= layers.Dense(num_classes, activation='softmax')(x)

    model = models.Model(inp, out)
    model.compile(optimizer='adam',
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])
    return model

def class_weights(y, num_classes):
    counts = np.bincount(y, minlength=num_classes).astype(np.float32)
    weights = (len(y) / (num_classes*np.maximum(counts,1)))
    return {i: float(weights[i]) for i in range(num_classes)}

def main():
    files = list_npz()
    if not files:
        print("No hay .npz en OUT_DIR. Corre extract_landmarks.py primero."); return
    label_map = load_label_map()
    num_classes = len(label_map)
    train_files, val_files = split(files, VAL_SPLIT)

    # Para class weights necesitamos y_train:
    y_train = np.array([int(np.load(f)["y"]) for f in train_files], np.int32)

    train_ds,(T,D) = make_ds(train_files, BATCH_SIZE, shuffle=True)
    val_ds,_       = make_ds(val_files,   BATCH_SIZE, shuffle=False)

    model = build_model(T,D,num_classes)
    cw = class_weights(y_train, num_classes)
    cbs = [
        tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=3, min_lr=1e-6),
        tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=6, restore_best_weights=True),
    ]
    model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, class_weight=cw, callbacks=cbs, verbose=1)

    model.save(MODEL_PATH); print("✅ Modelo:", MODEL_PATH)

    # TFLite INT8 (representative opcional)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tfl = converter.convert()
    open(TFLITE_PATH, "wb").write(tfl)
    print("✅ TFLite:", TFLITE_PATH)
    print(f"Input esperado por TFLite: shape [1,{T},{D}] (float32)")

if __name__=="__main__":
    main()
