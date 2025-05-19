import firebase_admin
from firebase_admin import credentials, db, storage

firebase_app = None

def initialize_firebase():
    global firebase_app
    if not firebase_app:
        cred = credentials.Certificate("singlanguage-credentials.json")
        firebase_app = firebase_admin.initialize_app(cred, {
            'databaseURL': 'https://singlanguage-d953b-default-rtdb.firebaseio.com/',
            'storageBucket': 'singlanguage-d953b.firebasestorage.app'
        })


def upload_file(file_path, storage_path):
    initialize_firebase()
    bucket = storage.bucket()
    blob = bucket.blob(storage_path)
    blob.upload_from_filename(file_path)
    return storage_path  # Devuelve ruta relativa

def save_data(reference, data):
    initialize_firebase()
    ref = db.reference(reference)
    ref.push(data)

def get_existing_files(reference):
    initialize_firebase()
    ref = db.reference(reference)
    data = ref.get() or {}
    
    existing = set()
    for categoria in data.values():
        if isinstance(categoria, dict):
            for doc in categoria.values():
                if isinstance(doc, dict) and 'file_url' in doc:
                    existing.add(doc['file_url'])
    return existing