import cv2
import time
import os
import numpy as np
from modules.hand_tracking import process_hands

# Directorio base de almacenamiento
capturas_dir = "captures"

# Asegurar que el directorio base existe
if not os.path.exists(capturas_dir):
    os.makedirs(capturas_dir)

# Asegurar que solo una instancia del script se ejecuta
cv2.destroyAllWindows()

# Inicializar la cámara
cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("No se pudo acceder a la cámara.")
    exit()

cv2.namedWindow("Captura", cv2.WINDOW_NORMAL)

# Solicitar palabra/frase al usuario
def solicitar_palabra():
    palabra = input("📝 Ingresa la palabra o frase a capturar: ").strip()
    while not palabra:
        palabra = input("⚠️ La palabra no puede estar vacía. Ingresa una palabra o frase: ").strip()
    return palabra

palabra = solicitar_palabra()

# Crear carpeta para la palabra/frase
def crear_directorio(palabra):
    palabra_dir = os.path.join(capturas_dir, palabra.replace(" ", "_"))
    if not os.path.exists(palabra_dir):
        os.makedirs(palabra_dir)
    return palabra_dir

palabra_dir = crear_directorio(palabra)
print(f"📂 Guardando en: {palabra_dir}")

# Variables para video
grabando = False
out = None

print("Presiona 'c' para capturar imagen, 'v' para iniciar/terminar grabación de video, 'n' para cambiar palabra, 'q' para salir.")

while True:
    font = cv2.FONT_HERSHEY_SIMPLEX 
    ret, frame = cap.read()
    if not ret:
        break

    # Verificar si la ventana fue cerrada
    if cv2.getWindowProperty("Captura", cv2.WND_PROP_VISIBLE) < 1:
        break

    # Convertir a RGB para procesar manos
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    # Procesar las manos
    frame = process_hands(frame, frame_rgb)

    # Calcular dimensiones del texto
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 1
    font_thickness = 3
    text_lines = [
        "Presiona 'c' para capturar imagen, ",
        "'v' para iniciar/terminar video,",
        "'n' para cambiar palabra,",
        "'q' para salir."
    ]

    # Calcular la altura requerida para el cuadro de texto
    line_height = 20
    cuadro_texto_altura = len(text_lines) * (line_height + 20) + 20
    ancho_texto = frame.shape[1]

    # Crear el cuadro de texto
    instrucciones = 255 * np.ones((cuadro_texto_altura, ancho_texto, 3), dtype=np.uint8)

    # Dibujar las instrucciones
    y_offset = 40
    for line in text_lines:
        # Texto negro encima del borde
        cv2.putText(instrucciones, line, (10, y_offset), font, font_scale, (0, 0, 0), font_thickness)
        y_offset += line_height + 20

    # Combinar video e instrucciones
    output_frame = cv2.vconcat([frame, instrucciones])

    # Mostrar frame combinado
    cv2.imshow("Captura", output_frame)
    key = cv2.waitKey(1) & 0xFF

    # Capturar Imagen
    if key == ord('c'):
        timestamp = int(time.time())
        image_path = os.path.join(palabra_dir, f"captura_{timestamp}.jpg")
        cv2.imwrite(image_path, frame)
        print(f"✅ Imagen guardada: {image_path}")

    # Iniciar o Finalizar Video
    elif key == ord('v'):
        if not grabando:
            # Iniciar grabación
            timestamp = int(time.time())
            video_path = os.path.join(palabra_dir, f"video_{timestamp}.mp4")
            fourcc = cv2.VideoWriter_fourcc(*'XVID')
            fps = 30
            out = cv2.VideoWriter(video_path, fourcc, fps, (640, 480))
            grabando = True
            print(f"🎥 Grabación iniciada: {video_path}")
        else:
            # Finalizar grabación
            grabando = False
            out.release()
            print(f"🛑 Grabación finalizada: {video_path}")

    # Guardar Frame en Video
    if grabando and out is not None:
        out.write(frame)

    # Cambiar de palabra o frase
    elif key == ord('n'):
        palabra = solicitar_palabra()
        palabra_dir = crear_directorio(palabra)
        print(f"📂 Ahora guardando en: {palabra_dir}")

    # Salir
    elif key == ord('q'):
        if grabando and out is not None:
            out.release()
            print(f"🛑 Grabación finalizada: {video_path}")
        break

# Liberar la cámara y cerrar ventanas
cap.release()
cv2.destroyAllWindows()
