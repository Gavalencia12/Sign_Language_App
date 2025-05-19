import sys
import os
import cv2
import numpy as np
import mediapipe as mp
from PySide6.QtWidgets import (QApplication, QWidget, QLabel, QVBoxLayout, 
                              QHBoxLayout, QPushButton)
from PySide6.QtCore import QTimer, Qt
from PySide6.QtGui import QImage, QPixmap
from keras.models import load_model

class SignLanguageTranslator(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Traductor de Lenguaje de Señas")
        self.setFixedSize(1280, 720)
        
        # Configuración de MediaPipe
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=1,
            min_detection_confidence=0.7,
            min_tracking_confidence=0.5)
        
        self.mp_drawing = mp.solutions.drawing_utils
        
        # Cargar modelo entrenado
        self.model = load_model(os.path.join('model', 'modelo.h5'))
        self.classes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 
                       'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 
                       'U', 'V', 'W', 'X', 'Y', 'Z']
        
        # Configurar interfaz
        self.init_ui()
        self.init_camera()
        
    def init_ui(self):
        # Widgets
        self.video_label = QLabel()
        self.video_label.setAlignment(Qt.AlignCenter)
        
        self.result_label = QLabel("Letra detectada: ")
        self.result_label.setAlignment(Qt.AlignCenter)
        self.result_label.setStyleSheet("font-size: 48px; font-weight: bold;")
        
        # Layout
        layout = QVBoxLayout()
        layout.addWidget(self.video_label)
        layout.addWidget(self.result_label)
        
        self.setLayout(layout)
        
    def init_camera(self):
        self.cap = cv2.VideoCapture(0)
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_frame)
        self.timer.start(30)
        
    def preprocess_landmarks(self, landmarks):
        # Convertir landmarks a array normalizado
        lm_array = []
        for lm in landmarks.landmark:
            lm_array.extend([lm.x, lm.y, lm.z])
        return np.array(lm_array).reshape(1, -1)
        
    def update_frame(self):
        ret, frame = self.cap.read()
        if not ret:
            return
            
        # Detección de manos
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.hands.process(frame_rgb)
        
        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                # Dibujar landmarks
                self.mp_drawing.draw_landmarks(
                    frame, hand_landmarks, self.mp_hands.HAND_CONNECTIONS)
                
                # Preprocesar y predecir
                processed_data = self.preprocess_landmarks(hand_landmarks)
                prediction = self.model.predict(processed_data)
                predicted_class = np.argmax(prediction)
                
                # Actualizar resultado
                self.result_label.setText(
                    f"Letra detectada: {self.classes[predicted_class]}")
        
        # Mostrar frame en la UI
        h, w, ch = frame.shape
        bytes_per_line = ch * w
        convert_to_qt_format = QImage(
            frame.data, w, h, bytes_per_line, QImage.Format_BGR888)
        pixmap = QPixmap.fromImage(convert_to_qt_format)
        self.video_label.setPixmap(pixmap)
        
    def closeEvent(self, event):
        self.cap.release()
        event.accept()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    
    # Cargar estilos
    with open(os.path.join('style', 'styles.qss'), 'r') as f:
        app.setStyleSheet(f.read())
        
    window = SignLanguageTranslator()
    window.show()
    sys.exit(app.exec())