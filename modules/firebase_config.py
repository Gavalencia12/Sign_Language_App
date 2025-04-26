import firebase_admin
from firebase_admin import credentials, db, storage

# Ruta al archivo JSON de credenciales (descárgalo desde Firebase)
cred = credentials.Certificate("singlanguage-credentials.json")

# Inicializar la conexión con la base de datos
firebase_admin.initialize_app(cred, {
    'storageBucket': 'singlanguage-d953b.firebasestorage.app',  # Reemplaza con tu bucket real
    'databaseURL': 'https://singlanguage-d953b-default-rtdb.firebaseio.com'  # Reemplaza con tu URL de Realtime Database
})

def upload_file(file_path, storage_path):
    """Sube un archivo (imagen o video) a Firebase Storage y devuelve su URL pública."""
    bucket = storage.bucket()
    blob = bucket.blob(storage_path)

    blob.upload_from_filename(file_path)
    blob.make_public()  # Hacerlo accesible públicamente

    return blob.public_url  # Devolver la URL del archivo

def save_data(reference, data):
    """Guarda datos en Firebase Realtime Database."""
    ref = db.reference(reference)
    ref.push(data)  # Agregar los datos a la referencia

def get_existing_files(reference):
    """Obtiene la lista de archivos ya guardados en Firebase Database."""
    ref = db.reference(reference)
    data = ref.get()

    if not data:
        return set()  # Si no hay archivos, regresar un conjunto vacío

    return set(entry["file_url"] for entry in data.values() if "file_url" in entry)