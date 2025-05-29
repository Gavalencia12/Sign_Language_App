import sys
import os
import cv2
import time
from PySide6.QtWidgets import (
    QApplication, QWidget, QLabel, QPushButton, QVBoxLayout, QHBoxLayout, QLineEdit
)
from PySide6.QtCore import QTimer, Qt
from PySide6.QtGui import QImage, QPixmap, QKeySequence, QShortcut

# Configuración MediaPipe
import mediapipe as mp
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils  # Utilidades para dibujar los puntos
hands_detector = mp_hands.Hands(static_image_mode=True, max_num_hands=2)  # Solo 1 mano por ahora


def detectar_mano_con_mediapipe(img_bgr):
    """
    Detecta si hay al menos una mano en la imagen usando MediaPipe.
    Devuelve la imagen con los puntos dibujados y el resultado de detección.
    """
    img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)  # Convertir imagen a RGB
    resultado = hands_detector.process(img_rgb)
    
    # Dibujar los puntos de la mano si se detecta
    if resultado.multi_hand_landmarks:
        for hand_landmarks in resultado.multi_hand_landmarks:
            mp_drawing.draw_landmarks(
                img_bgr,
                hand_landmarks,
                mp_hands.HAND_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2))
    
    return resultado.multi_hand_landmarks is not None  # Verifica si hay manos


def procesar_y_validar_mano(img_bgr):
    """
    Verifica si hay una mano usando solo MediaPipe.
    """
    return detectar_mano_con_mediapipe(img_bgr)  # Solo verifica con MediaPipe


class VideoApp(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Captura de Cámara - Navegación por Teclado")
        self.setFixedSize(900, 800)

        # Widgets principales
        self.label_video = QLabel("Esperando cámara...")
        self.label_video.setAlignment(Qt.AlignCenter)
        self.label_video.setObjectName("label_video")  # Para estilos CSS

        self.label_estado = QLabel("🟢 Escribe una palabra y presiona guardar")
        self.label_estado.setAlignment(Qt.AlignCenter)

        self.input_palabra = QLineEdit()
        self.input_palabra.setPlaceholderText("Escribe aquí la palabra o frase...")

        # Botones con teclas de acceso directo mostradas
        self.btn_guardar_palabra = QPushButton("💾 Guardar Palabra (G)")
        self.btn_capturar = QPushButton("📸 Capturar (C)")
        self.btn_grabar = QPushButton("🎥 Grabar (R)")
        self.btn_salir = QPushButton("❌ Salir (Q)")

        # Configurar teclas de acceso directo
        self.setup_shortcuts()

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

        # Etiqueta con instrucciones de teclado
        self.label_instrucciones = QLabel(
            "⌨️ Teclas: [G] Guardar | [C] Capturar | [R] Grabar | [Q] Salir | [Tab] Navegar | [Enter] Activar"
        )
        self.label_instrucciones.setAlignment(Qt.AlignCenter)
        self.label_instrucciones.setStyleSheet("color: #666; font-size: 10px; padding: 5px;")

        layout = QVBoxLayout()
        layout.addWidget(self.label_video)
        layout.addLayout(palabra_layout)
        layout.addWidget(self.label_estado)
        layout.addLayout(controles_layout)
        layout.addWidget(self.label_instrucciones)
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

        # Conexiones de botones
        self.btn_guardar_palabra.clicked.connect(self.guardar_palabra)
        self.btn_capturar.clicked.connect(self.capturar_imagen)
        self.btn_grabar.clicked.connect(self.toggle_grabacion)
        self.btn_salir.clicked.connect(self.close)

        # Configurar orden de tabulación
        self.setTabOrder(self.input_palabra, self.btn_guardar_palabra)
        self.setTabOrder(self.btn_guardar_palabra, self.btn_capturar)
        self.setTabOrder(self.btn_capturar, self.btn_grabar)
        self.setTabOrder(self.btn_grabar, self.btn_salir)

    def setup_shortcuts(self):
        """Configura los atajos de teclado"""
        # Atajo para guardar palabra (G)
        self.shortcut_guardar = QShortcut(QKeySequence("G"), self)
        self.shortcut_guardar.activated.connect(self.guardar_palabra)

        # Atajo para capturar (C)
        self.shortcut_capturar = QShortcut(QKeySequence("C"), self)
        self.shortcut_capturar.activated.connect(self.capturar_imagen)

        # Atajo para grabar (R de Record)
        self.shortcut_grabar = QShortcut(QKeySequence("R"), self)
        self.shortcut_grabar.activated.connect(self.toggle_grabacion)

        # Atajo para salir (Q de Quit)
        self.shortcut_salir = QShortcut(QKeySequence("Q"), self)
        self.shortcut_salir.activated.connect(self.close)

        # También agregar Escape para salir
        self.shortcut_escape = QShortcut(QKeySequence("Escape"), self)
        self.shortcut_escape.activated.connect(self.close)

        # Enter para activar el botón con foco
        self.shortcut_enter = QShortcut(QKeySequence("Return"), self)
        self.shortcut_enter.activated.connect(self.activar_boton_con_foco)

        # Espacio para activar el botón con foco
        self.shortcut_space = QShortcut(QKeySequence("Space"), self)
        self.shortcut_space.activated.connect(self.activar_boton_con_foco)

    def activar_boton_con_foco(self):
        """Activa el botón que actualmente tiene el foco"""
        widget_con_foco = self.focusWidget()
        if isinstance(widget_con_foco, QPushButton) and widget_con_foco.isEnabled():
            widget_con_foco.click()

    def keyPressEvent(self, event):
        """Maneja eventos de teclado personalizados"""
        # Si el input de texto tiene foco, permitir escritura normal
        if self.input_palabra.hasFocus():
            super().keyPressEvent(event)
            return

        # Manejar teclas especiales
        key = event.key()
        
        if key == Qt.Key_F1:
            self.mostrar_ayuda()
        else:
            super().keyPressEvent(event)

    def mostrar_ayuda(self):
        """Muestra información de ayuda sobre las teclas"""
        ayuda = """
        AYUDA - NAVEGACIÓN POR TECLADO:
        
        • G: Guardar palabra
        • C: Capturar imagen
        • R: Grabar video
        • Q o Escape: Salir
        • Tab: Navegar entre elementos
        • Enter o Espacio: Activar botón seleccionado
        • F1: Mostrar esta ayuda
        
        Primero escribe una palabra y presiona G para empezar.
        """
        self.label_estado.setText(ayuda.strip())

    def guardar_palabra(self):
        # Si el input no tiene foco, enfocarle primero para que el usuario pueda escribir
        if not self.input_palabra.hasFocus() and not self.input_palabra.text().strip():
            self.input_palabra.setFocus()
            return
            
        texto = self.input_palabra.text().strip()
        if texto:
            self.palabra = texto
            self.carpeta = self.crear_directorio(self.palabra)
            self.label_estado.setText(f"📂 Guardando en: {self.palabra}")
            self.btn_capturar.setEnabled(True)
            self.btn_grabar.setEnabled(True)
            # Dar foco al botón de capturar para navegación fluida
            self.btn_capturar.setFocus()
        else:
            self.label_estado.setText("⚠️ Debes escribir una palabra válida.")
            self.btn_capturar.setEnabled(False)
            self.btn_grabar.setEnabled(False)
            self.input_palabra.setFocus()

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

        # Procesar la imagen para detectar manos (esto dibujará los puntos)
        _ = detectar_mano_con_mediapipe(frame)

        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        img = QImage(frame_rgb.data, frame_rgb.shape[1], frame_rgb.shape[0], QImage.Format_RGB888)
        self.label_video.setPixmap(QPixmap.fromImage(img))

        if self.grabando and self.out:
            self.out.write(frame)

    def capturar_imagen(self):
        if not self.btn_capturar.isEnabled():
            self.label_estado.setText("⚠️ Primero debes guardar una palabra.")
            return
            
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
        if not self.btn_grabar.isEnabled():
            self.label_estado.setText("⚠️ Primero debes guardar una palabra.")
            return
            
        if not self.grabando and self.carpeta:
            timestamp = int(time.time())
            video_path = os.path.join(self.carpeta, f"video_{timestamp}.mp4")
            width = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            self.out = cv2.VideoWriter(video_path, cv2.VideoWriter_fourcc(*'XVID'), 30, (width, height))
            self.grabando = True
            self.btn_grabar.setText("⏹️ Detener Grabación (R)")
            self.label_estado.setText("🔴 Grabando video...")
        else:
            self.grabando = False
            if self.out:
                self.out.release()
            self.btn_grabar.setText("🎥 Grabar (R)")
            self.label_estado.setText("🛑 Grabación finalizada")

    def closeEvent(self, event):
        if self.grabando and self.out:
            self.out.release()
        self.cap.release()
        event.accept()


if __name__ == "__main__":
    app = QApplication(sys.argv)

    # Cargar estilos CSS externos si existe
    css_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "style", "styles.qss"))
    if os.path.exists(css_path):
        app.setStyleSheet(open(css_path).read())

    ventana = VideoApp()
    ventana.show()
    sys.exit(app.exec())