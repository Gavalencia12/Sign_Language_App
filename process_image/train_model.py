import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.python.keras import layers  # o simplemente:
import tensorflow as tf
from tensorflow import keras
from keras import layers
import mediapipe as mp
import cv2

# Configuración MediaPipe para detección de manos
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=True, max_num_hands=1)

def extract_hand_features(image_path):
    """Extrae características de la mano usando MediaPipe"""
    image = cv2.imread(image_path)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = hands.process(image_rgb)
    
    if results.multi_hand_landmarks:
        hand_landmarks = results.multi_hand_landmarks[0]
        features = []
        for landmark in hand_landmarks.landmark:
            features.extend([landmark.x, landmark.y, landmark.z])
        return np.array(features)
    return None

def load_dataset(data_dir):
    """Carga el dataset desde las carpetas de Firebase"""
    features = []
    labels = []
    label_map = {}
    
    # Recorrer carpetas (cada una representa una letra/palabra)
    for label_idx, class_dir in enumerate(os.listdir(data_dir)):
        label_map[label_idx] = class_dir
        class_path = os.path.join(data_dir, class_dir)
        
        for image_file in os.listdir(class_path):
            image_path = os.path.join(class_path, image_file)
            feature = extract_hand_features(image_path)
            
            if feature is not None:
                features.append(feature)
                labels.append(label_idx)
    
    return np.array(features), np.array(labels), label_map

def build_model(input_shape, num_classes):
    """Construye el modelo de TensorFlow"""
    model = keras.Sequential([
        layers.Input(shape=input_shape),
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.3),
        layers.Dense(64, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(num_classes, activation='softmax')
    ])
    
    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    return model

def train():
    # Configuración
    DATA_DIR = "images_for_training"
    MODEL_PATH = "sign_language_model.h5"
    
    # Cargar y preparar datos
    X, y, label_map = load_dataset(DATA_DIR)
    num_classes = len(label_map)
    
    # Dividir datos
    split = int(0.8 * len(X))
    X_train, X_test = X[:split], X[split:]
    y_train, y_test = y[:split], y[split:]
    
    # Construir y entrenar modelo
    model = build_model((X_train.shape[1],), num_classes)
    model.fit(
        X_train, y_train,
        validation_data=(X_test, y_test),
        epochs=30,
        batch_size=32
    )
    
    # Guardar modelo
    model.save(MODEL_PATH)
    np.save("label_map.npy", label_map)
    print("Modelo entrenado y guardado correctamente!")

if __name__ == "__main__":
    train()