import os
import cv2
import sys
import traceback
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))  # Añadir ruta del proyecto

from modules.firebase_config import initialize_firebase, upload_file, save_data, get_existing_files

def main():
    # Inicializar Firebase al inicio
    print("Inicializando Firebase...")
    initialize_firebase()
    print("Firebase inicializado. Comenzando proceso de subida...")

    capturas_dir = "captures"

    if not os.path.exists(capturas_dir):
        print("No hay directorio de capturas. Creando directorio...")
        os.makedirs(capturas_dir)
        print(f"Directorio '{capturas_dir}' creado. Por favor coloque las imágenes allí y ejecute el script nuevamente.")
        return

    # Verificar si hay archivos para subir
    files_to_process = []
    for root, _, files in os.walk(capturas_dir):
        for filename in files:
            if filename.endswith((".jpg", ".png", ".mp4", ".avi", ".mov")):
                files_to_process.append(os.path.join(root, filename))
    
    if not files_to_process:
        print(f"No hay archivos en '{capturas_dir}' para subir. Por favor añada imágenes o videos.")
        return

    print(f"Se encontraron {len(files_to_process)} archivos para procesar.")

    # Obtener archivos existentes (rutas relativas)
    try:
        existing_files = get_existing_files("entrenamiento/multimedia")
        print(f"Verificados {len(existing_files)} archivos existentes en Firebase.")
    except Exception as e:
        print(f"⚠️ Error al obtener archivos existentes: {str(e)}")
        existing_files = set()

    image_extensions = (".jpg", ".png")
    video_extensions = (".mp4", ".avi", ".mov")
    allowed_extensions = image_extensions + video_extensions

    processed_count = 0
    error_count = 0

    for root, _, files in os.walk(capturas_dir):
        for filename in files:
            if filename.endswith(allowed_extensions):
                file_path = os.path.join(root, filename)
                relative_path = os.path.relpath(file_path, capturas_dir)
                parts = relative_path.split(os.sep)
                categoria = parts[0] if len(parts) > 1 else "sin_categoria"
                storage_path = f"captures/{relative_path.replace(os.sep, '/')}"

                try:
                    print(f"Procesando: {filename}")
                    
                    if storage_path in existing_files:
                        print(f"⚠️ Archivo {filename} ya está en Firebase. Saltando...")
                        continue

                    # Procesamiento de imágenes
                    if filename.endswith(image_extensions):
                        img = cv2.imread(file_path, cv2.IMREAD_GRAYSCALE)
                        if img is None:
                            print(f"⚠️ Error leyendo {filename}. Saltando...")
                            continue
                        cv2.imwrite(file_path, img)

                    # Procesamiento de videos
                    elif filename.endswith(video_extensions):
                        file_base, file_ext = os.path.splitext(file_path)
                        temp_video_path = f"{file_base}_processed{file_ext}"
                        
                        cap = cv2.VideoCapture(file_path)
                        if not cap.isOpened():
                            print(f"⚠️ Error abriendo {filename}. Saltando...")
                            continue
                        
                        fps = int(cap.get(cv2.CAP_PROP_FPS)) or 30
                        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
                        out = cv2.VideoWriter(temp_video_path, fourcc, fps, (224, 224), 0)

                        while cap.isOpened():
                            ret, frame = cap.read()
                            if not ret:
                                break
                            gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                            resized_frame = cv2.resize(gray_frame, (224, 224))
                            out.write(cv2.merge([resized_frame]))

                        cap.release()
                        out.release()
                        os.replace(temp_video_path, file_path)

                    # Subir archivo y guardar metadatos
                    try:
                        # Subir a Storage y obtener ruta relativa
                        file_url = upload_file(file_path, storage_path)
                        
                        # Guardar en Realtime Database
                        data = {
                            "file_url": file_url,  # Ruta relativa en Storage
                            "type": "video" if filename.endswith(video_extensions) else "image",
                            "timestamp": {".sv": "timestamp"}
                        }
                        save_data(f"entrenamiento/multimedia/{categoria}", data)
                        
                        print(f"✅ Subido: {storage_path} | Categoría: {categoria}")
                        
                        # Limpiar archivo local
                        os.remove(file_path)
                        print(f"🗑️ Eliminado local: {file_path}")
                        processed_count += 1

                    except Exception as e:
                        print(f"🔥 Error crítico procesando {filename}: {str(e)}")
                        traceback.print_exc()
                        error_count += 1
                
                except Exception as e:
                    print(f"⚠️ Error inesperado con {filename}: {str(e)}")
                    error_count += 1
    
    print("\n=== Resumen ===")
    print(f"Archivos procesados correctamente: {processed_count}")
    print(f"Archivos con errores: {error_count}")
    print("Proceso finalizado.")

if __name__ == "__main__":
    main()