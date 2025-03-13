import cv2
import time
import os

# Crear la carpeta si no existe
captures_dir = "captures"
if not os.path.exists(captures_dir):
    os.makedirs(captures_dir)

# Asegurar que solo una instancia del script se ejecuta
cv2.destroyAllWindows()

# Inicializar la cámara
cap = cv2.VideoCapture(0)
if not cap.isOpened():
    print("No se pudo acceder a la cámara.")
    exit()

# Obtener ancho y alto del video
frame_width = int(cap.get(3))
frame_height = int(cap.get(4))
fps = 20  # FPS del video

# Generar nombre de archivo con timestamp
timestamp = int(time.time())
video_path = os.path.join(captures_dir, f"video_{timestamp}.mp4")

# Definir el códec y crear el objeto VideoWriter
fourcc = cv2.VideoWriter_fourcc(*'mp4v')  
out = cv2.VideoWriter(video_path, fourcc, fps, (frame_width, frame_height))

# Bandera para controlar la grabación
recording = False

# Crear una ventana nombrada
cv2.namedWindow("Captura de Video", cv2.WINDOW_NORMAL)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Si está grabando, guardar los frames en el video
    if recording:
        out.write(frame)

    cv2.imshow("Captura de Video", frame)

    key = cv2.waitKey(1) & 0xFF

    if key == ord('r'):  # Presionar 'r' para comenzar/detener la grabación
        recording = not recording
        if recording:
            print("🎥 Grabación iniciada...")
        else:
            print("🛑 Grabación detenida.")

    elif key == ord('q'):  # Presionar 'q' para salir
        break

# Liberar la cámara y cerrar la ventana correctamente
cap.release()
out.release()  # Guardar el video correctamente
cv2.destroyAllWindows()

print(f"✅ Video guardado: {video_path}")
