import sys
import cv2
import numpy as np
import tensorflow as tf
from PySide6.QtWidgets import QApplication, QWidget, QLabel, QVBoxLayout
from PySide6.QtCore import QTimer, Qt
from PySide6.QtGui import QImage, QPixmap
import mediapipe as mp

class SignLanguagePredictor(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Traductor de Lengua de Señas - IA")
        self.setFixedSize(1000, 720)
        self.setup_ui()
        self.setup_camera()
        self.load_ai_components()
        
        # Configurar temporizador para actualizar el frame
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_frame)
        self.timer.start(30)

    def setup_ui(self):
        self.setStyleSheet("""
            QWidget {
                background-color: #2c3e50;
                color: #ecf0f1;
                font-family: 'Arial';
            }
            QLabel#video_frame {
                border: 3px solid #3498db;
                border-radius: 15px;
                background-color: #000000;
            }
            QLabel#prediction_text {
                font-size: 28px;
                color: #2ecc71;
                padding: 20px;
                background-color: #34495e;
                border-radius: 10px;
                margin: 15px;
                qproperty-alignment: AlignCenter;
            }
            QLabel#title {
                font-size: 36px;
                font-weight: bold;
                color: #3498db;
                padding: 20px;
                qproperty-alignment: AlignCenter;
            }
            QLabel#confidence {
                font-size: 20px;
                color: #bdc3c7;
                padding: 15px;
                qproperty-alignment: AlignCenter;
            }
        """)

        # Crear componentes
        self.title_label = QLabel("TRADUCTOR EN TIEMPO REAL")
        self.title_label.setObjectName("title")

        self.video_label = QLabel()
        self.video_label.setObjectName("video_frame")
        self.video_label.setFixedSize(960, 540)  # Tamaño fijo para el video (16:9)

        self.prediction_label = QLabel("Esperando detección...")
        self.prediction_label.setObjectName("prediction_text")

        self.confidence_label = QLabel("Confianza: 0%")
        self.confidence_label.setObjectName("confidence")

        # Configurar layout
        layout = QVBoxLayout()
        layout.addWidget(self.title_label)
        layout.addWidget(self.video_label, alignment=Qt.AlignCenter)  # Centrar horizontalmente
        layout.addWidget(self.prediction_label)
        layout.addWidget(self.confidence_label)
        self.setLayout(layout)

    def setup_camera(self):
        self.cap = cv2.VideoCapture(0)
        if not self.cap.isOpened():
            print("Error: No se pudo acceder a la cámara")
            sys.exit()

    def load_ai_components(self):
        # Cargar modelo y configuración MediaPipe
        self.model = tf.keras.models.load_model("sign_language_model.h5")
        self.label_map = np.load("label_map.npy", allow_pickle=True).item()
        
        # Inicializar MediaPipe Hands
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=1,
            min_detection_confidence=0.7,
            min_tracking_confidence=0.5
        )

    def extract_landmarks(self, frame):
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.hands.process(frame_rgb)
        
        if results.multi_hand_landmarks:
            hand_landmarks = results.multi_hand_landmarks[0]
            return np.array([[lm.x, lm.y, lm.z] for lm in hand_landmarks.landmark]).flatten()
        return None

    def update_frame(self):
        ret, frame = self.cap.read()
        if not ret:
            return

        # Mostrar video
        self.display_video(frame)
        
        # Procesar y predecir
        landmarks = self.extract_landmarks(frame)
        if landmarks is not None:
            self.make_prediction(landmarks)

    def display_video(self, frame):
        # Redimensionar manteniendo la relación de aspecto para llenar el ancho
        h, w = frame.shape[:2]
        target_width = self.video_label.width()
        target_height = int(target_width * h / w)  # Mantener relación de aspecto
        
        # Redimensionar el frame
        resized_frame = cv2.resize(frame, (target_width, target_height))
        
        # Convertir a RGB y mostrar
        frame_rgb = cv2.cvtColor(resized_frame, cv2.COLOR_BGR2RGB)
        q_img = QImage(frame_rgb.data, target_width, target_height, QImage.Format_RGB888)
        self.video_label.setPixmap(QPixmap.fromImage(q_img))

    def make_prediction(self, landmarks):
        try:
            prediction = self.model.predict(landmarks.reshape(1, -1))
            predicted_class = np.argmax(prediction)
            confidence = prediction[0][predicted_class]
            
            self.update_prediction_ui(
                self.label_map[predicted_class],
                confidence
            )
        except Exception as e:
            print(f"Error en la predicción: {str(e)}")

    def update_prediction_ui(self, prediction, confidence):
        # Determinar color según confianza
        confidence_color = "#2ecc71" if confidence > 0.9 else "#f1c40f" if confidence > 0.7 else "#e74c3c"
        
        self.prediction_label.setText(f"✋ {prediction.upper()} ✋")
        self.confidence_label.setText(
            f"Confianza: <span style='color:{confidence_color};font-weight:bold;'>{confidence:.2%}</span>"
        )

    def closeEvent(self, event):
        self.cap.release()
        self.timer.stop()
        event.accept()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = SignLanguagePredictor()
    window.show()
    sys.exit(app.exec())