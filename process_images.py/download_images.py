import os
import requests
import firebase_admin
from firebase_admin import credentials, firestore, storage

# Configura Firebase Admin SDK
cred = credentials.Certificate("singlanguage-credentials.json")
firebase_admin.initialize_app(cred, {'storageBucket': 'singlanguage-d953b.firebasestorage.app'})

# Acceso a la base de datos de Firebase Realtime Database
db = firestore.client()
bucket = storage.bucket()

# Ruta donde se guardarán las imágenes descargadas
download_dir = "images_for_training"

if not os.path.exists(download_dir):
    os.makedirs(download_dir)

# Obtener los documentos de entrenamiento de Firebase
categoria_ref = db.collection("entrenamiento").document("multimedia").collections()

for categoria in categoria_ref:
    for doc in categoria.stream():
        file_url = doc.to_dict().get("file_url")
        if file_url:
            # Aquí puedes agregar lógica para filtrar solo las imágenes
            filename = file_url.split("/")[-1]
            file_path = os.path.join(download_dir, filename)

            # Descargar la imagen
            try:
                print(f"Descargando imagen: {file_url}")
                blob = bucket.blob(file_url)
                blob.download_to_filename(file_path)
                print(f"Imagen descargada: {file_path}")
            except Exception as e:
                print(f"Error al descargar {file_url}: {e}")

print("Descarga completada.")
