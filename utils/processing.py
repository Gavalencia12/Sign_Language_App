# utils/processing.py

import cv2
import mediapipe as mp

# === Configuración MediaPipe ===
mp_hands = mp.solutions.hands
hands_detector = mp_hands.Hands(static_image_mode=True, max_num_hands=1)


def detectar_mano_con_mediapipe(img_bgr):
    """
    Detecta si hay al menos una mano en la imagen usando MediaPipe.
    """
    img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
    resultado = hands_detector.process(img_rgb)
    return resultado.multi_hand_landmarks is not None


def validar_mano_por_brillo(img_bgr):
    """
    Heurística simple basada en escala de grises: detecta si hay "contenido" útil.
    """
    gris = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
    redimensionada = cv2.resize(gris, (224, 224))
    _, thresh = cv2.threshold(redimensionada, 50, 255, cv2.THRESH_BINARY)
    porcentaje_blanco = (cv2.countNonZero(thresh) / (224 * 224)) * 100
    return 5 < porcentaje_blanco < 70


def procesar_y_validar_mano(img_bgr):
    """
    Combina ambas validaciones: brillo y detección real de mano con MediaPipe.
    """
    if not validar_mano_por_brillo(img_bgr):
        return False
    return detectar_mano_con_mediapipe(img_bgr)
