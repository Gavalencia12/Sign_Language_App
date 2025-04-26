import sys
import os
import cv2
import time
from PySide6.QtWidgets import (
    QApplication, QWidget, QLabel, QPushButton, QVBoxLayout, QHBoxLayout, QLineEdit
)
from PySide6.QtCore import QTimer, Qt
from PySide6.QtGui import QImage, QPixmap

# Configuración MediaPipe
import mediapipe as mp
mp_hands = mp.solutions.hands
hands_detector = mp_hands.Hands(static_image_mode=True, max_num_hands=2)  # Solo 1 mano por ahora


def detectar_mano_con_mediapipe(img_bgr):
    """
    Detecta si hay al menos una mano en la imagen usando MediaPipe.
    """
    img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)  # Convertir imagen a RGB
    resultado = hands_detector.process(img_rgb)
    return resultado.multi_hand_landmarks is not None  # Verifica si hay manos


def procesar_y_validar_mano(img_bgr):
    """
    Verifica si hay una mano usando solo MediaPipe.
    """
    return detectar_mano_con_mediapipe(img_bgr)  # Solo verifica con MediaPipe


class VideoApp(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Captura de Cámara")
        self.setFixedSize(900, 800)

        # Widgets principales
        self.label_video = QLabel("Esperando cámara...")
        self.label_video.setAlignment(Qt.AlignCenter)
        self.label_video.setObjectName("label_video")  # Para estilos CSS

        self.label_estado = QLabel("🟢 Escribe una palabra y presiona guardar")
        self.label_estado.setAlignment(Qt.AlignCenter)

        self.input_palabra = QLineEdit()
        self.input_palabra.setPlaceholderText("Escribe aquí la palabra o frase...")

        self.btn_guardar_palabra = QPushButton("💾 Guardar Palabra")
        self.btn_guardar_palabra.clicked.connect(self.guardar_palabra)

        self.btn_capturar = QPushButton("📸 Capturar")
        self.btn_grabar = QPushButton("🎥 Grabar")
        self.btn_salir = QPushButton("❌ Salir")

        self.btn_capturar.setEnabled(False)
        self.btn_grabar.setEnabled(False)

        # Layouts
        palabra_layout = QHBoxLayout()
        palabra_layout.addWidget(self.input_palabra)
        palabra_layout.addWidget(self.btn_guardar_palabra)

        controles_layout = QHBoxLayout()
        controles_layout.addWidget(self.btn_capturar)
        controles_layout.addWidget(self.btn_grabar)
        controles_layout.addWidget(self.btn_salir)

        layout = QVBoxLayout()
        layout.addWidget(self.label_video)
        layout.addLayout(palabra_layout)
        layout.addWidget(self.label_estado)
        layout.addLayout(controles_layout)
        self.setLayout(layout)

        # Variables
        self.palabra = ""
        self.carpeta = None
        self.grabando = False
        self.out = None

        # Cámara
        self.cap = cv2.VideoCapture(0)

        # Timer
        self.timer = QTimer()
        self.timer.timeout.connect(self.mostrar_frame)
        self.timer.start(30)

        # Conexiones
        self.btn_capturar.clicked.connect(self.capturar_imagen)
        self.btn_grabar.clicked.connect(self.toggle_grabacion)
        self.btn_salir.clicked.connect(self.close)

    def guardar_palabra(self):
        texto = self.input_palabra.text().strip()
        if texto:
            self.palabra = texto
            self.carpeta = self.crear_directorio(self.palabra)
            self.label_estado.setText(f"📂 Guardando en: {self.palabra}")
            self.btn_capturar.setEnabled(True)
            self.btn_grabar.setEnabled(True)
        else:
            self.label_estado.setText("⚠️ Debes escribir una palabra válida.")
            self.btn_capturar.setEnabled(False)
            self.btn_grabar.setEnabled(False)

    def crear_directorio(self, palabra):
        base = "captures"
        if not os.path.exists(base):
            os.makedirs(base)
        path = os.path.join(base, palabra.replace(" ", "_"))
        if not os.path.exists(path):
            os.makedirs(path)
        return path

    def mostrar_frame(self):
        ret, frame = self.cap.read()
        if not ret:
            self.label_video.setText("❌ No se pudo capturar imagen.")
            return

        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        img = QImage(frame_rgb.data, frame_rgb.shape[1], frame_rgb.shape[0], QImage.Format_RGB888)
        self.label_video.setPixmap(QPixmap.fromImage(img))

        if self.grabando and self.out:
            self.out.write(frame)

    def capturar_imagen(self):
        ret, frame = self.cap.read()
        if ret and self.carpeta:
            if procesar_y_validar_mano(frame):  # Solo verificamos si hay una mano
                timestamp = int(time.time())
                path = os.path.join(self.carpeta, f"captura_{timestamp}.jpg")
                cv2.imwrite(path, frame)
                self.label_estado.setText(f"✅ Mano detectada. Imagen guardada: {path}")
            else:
                self.label_estado.setText("⚠️ No se detectó una mano. Imagen descartada.")

    def toggle_grabacion(self):
        if not self.grabando and self.carpeta:
            timestamp = int(time.time())
            video_path = os.path.join(self.carpeta, f"video_{timestamp}.mp4")
            width = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            self.out = cv2.VideoWriter(video_path, cv2.VideoWriter_fourcc(*'XVID'), 30, (width, height))
            self.grabando = True
            self.label_estado.setText("🔴 Grabando video...")
        else:
            self.grabando = False
            if self.out:
                self.out.release()
            self.label_estado.setText("🛑 Grabación finalizada")

    def closeEvent(self, event):
        if self.grabando and self.out:
            self.out.release()
        self.cap.release()
        event.accept()


if __name__ == "__main__":
    app = QApplication(sys.argv)

    # Cargar estilos CSS externos
    css_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "style", "styles.qss"))
    app.setStyleSheet(open(css_path).read())

    ventana = VideoApp()
    ventana.show()
    sys.exit(app.exec())
    
