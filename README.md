# Sign_Language_App

## Tabla de Contenido
- capture.py → captura las muestras y las ubica en la carpeta "capture"
- upload_images.py → Sube las imagenes a la base de datos (Firebase).

## Descripcion.
Application of Comouter Vision for Sign Language Recognition 

## Como instalar y Ejecutar el proyecto.
### Captura y Guardado de la imagenes:
1. Clonar el repositorio y descargar librerias
    - Descargar python con las librerias
        - OpenCV: Para el procesamiento de imágenes y videos, como la lectura de la cámara y la manipulación de archivos de imagen y video.
        - NumPy: Para la manipulación de matrices y la creación de arreglos numéricos, como los que se usan en las imágenes y los cuadros de texto.
        - Firebase: Para interactuar con Firebase, subir archivos y guardar datos en la base de datos en tiempo real.
        - Mediapipe: En el procesamiento de manos,rostro y torso.
    - Aquí se puden instalar: "pip install opencv-python opencv-python-headless numpy firebase-admin mediapipe"
2. Configurar y conectar a una base de datos
    - Configurar el archivo "firebase_config.py" a la base de datos.
    - modificar el " 'storageBucket' 'databaseURL' " con tu bucket real y tu tu URL de Realtime Database.
3. Ejecutar el archivo "capture.py" e ingreasar una palabra o frase para guardarlas.
4. Ejecutar el archivo "upload_images.py" para subir las imagenes a la base de datos.

## Como Utilizar el Proyecto.


## Creditos

## Badges
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![OpenCV](https://img.shields.io/badge/opencv-%23white.svg?style=for-the-badge&logo=opencv&logoColor=white)
![TensorFlow](https://img.shields.io/badge/TensorFlow-%23FF6F00.svg?style=for-the-badge&logo=TensorFlow&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
