import os
import sys
from modules.firebase_config import initialize_firebase  # Importación corregida
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from firebase_admin import db, storage

DOWNLOAD_DIR = "images_for_training"

def download_from_firebase():
    bucket = storage.bucket()
    rtdb_ref = db.reference('entrenamiento/multimedia')
    
    try:
        all_data = rtdb_ref.get() or {}
        print(f"Encontradas {len(all_data)} categorías")
        
        for categoria, documentos in all_data.items():
            categoria_dir = os.path.join(DOWNLOAD_DIR, categoria)
            os.makedirs(categoria_dir, exist_ok=True)
            print(f"\nProcesando categoría: {categoria}")
            
            # Verificar si documentos es un diccionario válido
            if isinstance(documentos, dict):
                for doc_id, doc_data in documentos.items():
                    if isinstance(doc_data, dict):
                        file_url = doc_data.get('file_url')
                        if file_url:
                            filename = file_url.split('/')[-1]
                            file_path = os.path.join(categoria_dir, filename)
                            
                            if os.path.exists(file_path):
                                print(f"✓ Ya existe: {filename}")
                                continue
                                
                            try:
                                blob = bucket.blob(file_url)
                                blob.download_to_filename(file_path)
                                print(f"↓ Descargado: {filename}")
                            except Exception as e:
                                print(f"✗ Error descargando {filename}: {str(e)}")
        
        return True
    
    except Exception as e:
        print(f"✗ Error en la comunicación: {str(e)}")
        return False

if __name__ == "__main__":
    print("=== Iniciando descarga desde Firebase ===")
    initialize_firebase()  # Usa la función del módulo
    
    if download_from_firebase():
        print("\n=== Proceso completado ===")
        print(f"Imágenes guardadas en: {os.path.abspath(DOWNLOAD_DIR)}")
    else:
        print("\n=== Proceso fallido ===")