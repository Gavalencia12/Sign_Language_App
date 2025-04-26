import os
import cv2
from modules.firebase_config import upload_file, save_data, get_existing_files

capturas_dir = "captures"

# Busca si hay archivos para subir
if not os.path.exists(capturas_dir):
    print("No hay archivos para subir.")
    exit()

# Obtener lista de archivos ya guardados en Firebase
existing_files = get_existing_files("entrenamiento/multimedia")  # Obtiene lista de URLs

# Extensiones permitidas
image_extensions = (".jpg", ".png")
video_extensions = (".mp4", ".avi", ".mov")
allowed_extensions = image_extensions + video_extensions

for root, _, files in os.walk(capturas_dir):
    for filename in files:
        if filename.endswith(allowed_extensions):
            file_path = os.path.join(root, filename)
            
            # Obtener la ruta relativa dentro de "captures/"
            relative_path = os.path.relpath(file_path, capturas_dir)

            # Extraer la primera carpeta como "categoría"
            parts = relative_path.split(os.sep)
            categoria = parts[0] if len(parts) > 1 else "sin_categoria"
            
            # Ruta en Firebase Storage respetando la estructura de carpetas
            storage_path = f"captures/{relative_path.replace(os.sep, '/')}"

            # Verificar si el archivo ya está en Firebase
            if storage_path in existing_files:
                print(f"⚠️ Archivo {filename} ya está en Firebase, no se sube nuevamente.")
                continue  # Saltar este archivo

            # **PROCESAR IMÁGENES**: Solo convertir a escala de grises sin redimensionar
            if filename.endswith(image_extensions):
                img = cv2.imread(file_path, cv2.IMREAD_GRAYSCALE)  # Convertir a escala de grises
                if img is None:
                    print(f"⚠️ No se pudo leer la imagen {filename}, se omite.")
                    continue

                # No redimensionamos, solo procesamos a escala de grises
                cv2.imwrite(file_path, img)  # Sobrescribir con la imagen procesada

            # **PROCESAR VIDEOS**
            elif filename.endswith(video_extensions):
                file_base, file_ext = os.path.splitext(file_path)
                temp_video_path = f"{file_base}_processed{file_ext}"  # Generar un nombre seguro

                cap = cv2.VideoCapture(file_path)
                if not cap.isOpened():
                    print(f"⚠️ No se pudo abrir el video {filename}, se omite.")
                    continue

                # Obtener FPS y codec del video original
                fps = int(cap.get(cv2.CAP_PROP_FPS))
                if fps < 1:  # Evitar valores inválidos de FPS
                    fps = 30  # Valor por defecto si el FPS no es válido
                
                fourcc = cv2.VideoWriter_fourcc(*'mp4v')

                # Crear el video de salida con resolución 224x224
                out = cv2.VideoWriter(temp_video_path, fourcc, fps, (224, 224), 0)

                while True:
                    ret, frame = cap.read()
                    if not ret:
                        break

                    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)  # Convertir frame a escala de grises
                    resized_frame = cv2.resize(gray_frame, (224, 224))  # Redimensionar frame
                    out.write(cv2.merge([resized_frame]))  # Escribir frame en video procesado

                cap.release()
                out.release()

                # Reemplazar el archivo original con el procesado
                os.replace(temp_video_path, file_path)

            # Subir archivo a Firebase Storage
            file_url = upload_file(file_path, storage_path)

            # Guardar URL en Firebase Realtime Database
            data = {
                "file_url": file_url,
                "type": "video" if filename.endswith(video_extensions) else "image"
            }

            save_data(f"entrenamiento/multimedia/{categoria}", data)

            print(f"✅ Archivo subido y guardado en Firebase Database ({categoria}): {file_url}")


            # Eliminar archivo después de subirlo correctamente
            try:
                os.remove(file_path)
                print(f"🗑️ Archivo eliminado: {file_path}")
            except Exception as e:
                print(f"⚠️ Error al eliminar {file_path}: {e}")
                
