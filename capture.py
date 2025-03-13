import cv2
import time
import os
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

# Crear una ventana nombrada (para evitar múltiples ventanas)
cv2.namedWindow("Captura de imágenes", cv2.WINDOW_NORMAL)

# Solicitar palabra/frase al usuario
palabra = input("📝 Ingresa la palabra o frase a capturar: ").strip()
while not palabra:
    palabra = input("⚠️ La palabra no puede estar vacía. Ingresa una palabra o frase: ").strip()

# Crear carpeta para la palabra/frase
palabra_dir = os.path.join(capturas_dir, palabra.replace(" ", "_"))
if not os.path.exists(palabra_dir):
    os.makedirs(palabra_dir)

print(f"📂 Guardando imágenes en: {palabra_dir}")

while True:
    ret, frame = cap.read()
    if not ret:
        break


    # Convertir el frame a RGB "BGR"
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    # Procesar las manos
    frame = process_hands(frame, frame_rgb)

    cv2.imshow("Captura de imágenes", frame)  # Solo una ventana

    key = cv2.waitKey(1) & 0xFF

    if key == ord('c'):  # Presionar 'c' para capturar imagen
        timestamp = int(time.time())
        image_path = os.path.join(palabra_dir, f"captura_{timestamp}.jpg")
        cv2.imwrite(image_path, frame)
        print(f"✅ Imagen guardada: {image_path}")

    elif key == ord('n'):  # Presionar 'n' para cambiar de palabra/frase
        palabra = input("📝 Ingresa una nueva palabra o frase: ").strip()
        while not palabra:
            palabra = input("⚠️ La palabra no puede estar vacía. Ingresa una palabra o frase: ").strip()

        # Crear nueva carpeta para la nueva palabra/frase
        palabra_dir = os.path.join(capturas_dir, palabra.replace(" ", "_"))
        if not os.path.exists(palabra_dir):
            os.makedirs(palabra_dir)

        print(f"📂 Ahora guardando imágenes en: {palabra_dir}")

    elif key == ord('q'):  # Presionar 'q' para salir
        break

# Liberar la cámara y cerrar la ventana correctamente
cap.release()
cv2.destroyAllWindows()
