import os
from modules.firebase_config import upload_file, save_data, get_existing_files

capturas_dir = "captures"

if not os.path.exists(capturas_dir):
    print("No hay archivos para subir.")
    exit()

# Obtener lista de archivos ya guardados en Firebase
existing_files = get_existing_files("entrenamiento/multimedia")  # Obtiene lista de URLs

# Extensiones permitidas (imágenes y videos)
allowed_extensions = (".jpg", ".png", ".mp4", ".avi", ".mov")

for root, _, files in os.walk(capturas_dir):
    for filename in files:
        if filename.endswith(allowed_extensions):
            file_path = os.path.join(root, filename)
            
            # Obtener la ruta relativa dentro de "captures/"
            relative_path = os.path.relpath(file_path, capturas_dir)
            
            # Ruta en Firebase Storage respetando la estructura de carpetas
            storage_path = f"captures/{relative_path.replace(os.sep, '/')}"

            # Verificar si el archivo ya está en Firebase
            if storage_path in existing_files:
                print(f"⚠️ Archivo {filename} ya está en Firebase, no se sube nuevamente.")
                continue  # Saltar este archivo

            # Subir archivo a Firebase Storage
            file_url = upload_file(file_path, storage_path)

            # Guardar URL en Firebase Realtime Database
            data = {
                "file_url": file_url,
                "type": "video" if filename.endswith(('.mp4', '.avi', '.mov')) else "image"
            }
            save_data("entrenamiento/multimedia", data)

            print(f"✅ Archivo subido y guardado en Firebase Database: {file_url}")

            # Eliminar archivo después de subirlo correctamente
            try:
                os.remove(file_path)
                print(f"🗑️ Archivo eliminado: {file_path}")
            except Exception as e:
                print(f"⚠️ Error al eliminar {file_path}: {e}")
