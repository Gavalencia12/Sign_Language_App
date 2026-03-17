# Sign_Language_App

## Tabla de Contenido
- `extract_landmarks.py`: Procesa videos e imágenes para generar secuencias de landmarks en formato `.npz`.
- `train_landmarks_gru.py`: Entrena la red neuronal y exporta los modelos `.h5` y `.tflite`.
- `predict.py`: Script de inferencia en tiempo real para pruebas con cámara web.
- `matriz.py`: Genera métricas de precisión, reporte de clasificación y la matriz de confusión.
- `lsm_health_gru_int8.tflite`: Modelo optimizado con soporte para `Select TF Ops`, listo para dispositivos Android.

## Descripcion.
**Aplicación de Visión Artificial para el reconocimiento de Lengua de Señas Mexicana en el campo semántico de la salud (Cita Médica de Primer Contacto).**

Este sistema utiliza **MediaPipe Holistic** para extraer puntos clave (landmarks) de manos, rostro y pose, procesando la información espacial y temporal a través de una red neuronal recurrente **GRU (Gated Recurrent Unit)**. El proyecto soluciona el problema de reconocimiento de secuencias temporales complejas, permitiendo identificar señas en movimiento continuo para facilitar la comunicación médico-paciente.

## Como instalar y Ejecutar el proyecto.

Se recomienda utilizar **Python 3.10** o **3.11**. Es una buena práctica crear un entorno virtual para no crear conflictos con otras librerías de tu sistema.

### Instalación en Windows

1. Descarga e instala [Python](https://www.python.org/). Asegúrate de marcar la opción "Add Python to PATH" durante la instalación.

2. Abre una terminal (Símbolo del sistema o PowerShell) y clona/descarga este repositorio.

3. Instala las dependencias necesarias ejecutando:
   ```bash
   pip install opencv-python numpy mediapipe tensorflow scikit-learn pandas matplotlib seaborn

### Instalación en Linux (Ubuntu)
Para Ubuntu (22.04 o superior), OpenCV y MediaPipe requieren algunas librerías gráficas del sistema operativo para funcionar correctamente con la cámara web.

1. Abre una terminal y actualiza los paquetes del sistema, instalando las dependencias de video:
   ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y python3-pip python3-venv libgl1-mesa-glx libglib2.0-0

2. Una vez instlado python crea un entorno virtual, actívalo e instala las librerías:
   ```bash
    python3 -m venv venv 
    source venv/bin/activate
    pip install opencv-python numpy mediapipe tensorflow scikit-learn pandas matplotlib seaborn


## Como Utilizar el Proyecto.

Para entrenar tu propio modelo o validar el existente, ejecuta los scripts estrictamente en este orden:

1. Extracción de Características (Landmarks)

Coloca los videos de muestra de cada seña dentro de sus respectivas carpetas en la ruta de origen (por ejemplo: `process_img_mp4/videos/`).
```bash
python extract_landmarks.py
```

**¿Qué hace?** Lee los videos, extrae las coordenadas 3D del cuerpo usando MediaPipe, las empaqueta en ventanas de 32 frames y las guarda como archivos .npz en la carpeta `landmarks_out/`. También genera el archivo `label_map.json`.

2. Entrenamiento del Modelo GRU
```bash
python train_landmarks_gru.py
```
**¿Qué hace?** Toma los archivos .npz generados y entrena la red neuronal recurrente. Al finalizar, guarda el modelo principal (`lsm_health_gru.h5`) y realiza una conversión optimizada para móviles (`lsm_health_gru_int8.tflite`).

3. Evaluación y Documentación
```bash
python matriz.py
```

**¿Qué hace?** Evalúa el modelo `.h5` con un conjunto de datos de prueba y genera la Matriz de Confusión en formato de imagen `(.png)` y un reporte en Excel `(.csv)`. Ideal para documentar la precisión del sistema.

4. Pruebas de Inferencia (Tiempo Real)
```bash
python predict.py
```
**¿Qué hace?** Enciende tu cámara. Realiza una seña frente a la cámara; el sistema detectará el movimiento, mostrará los puntos clave dibujados en tu cuerpo y, en la parte inferior, imprimirá la traducción de la seña junto con su porcentaje de certeza.

##  Arquitectura del Modelo (Deep Learning)

El núcleo de esta aplicación es una red neuronal secuencial diseñada para procesar series temporales de coordenadas espaciales. La arquitectura se compone de:

* **Capa de Entrada:** Recibe secuencias de 32 frames, donde cada frame contiene los puntos clave (landmarks) extraídos por MediaPipe (Manos, Rostro, Pose).
* **Capas GRU (Gated Recurrent Unit):** Se encargan de "recordar" el movimiento a lo largo del tiempo. Las GRU son ideales para este proyecto porque son más eficientes computacionalmente que las LSTM, permitiendo una ejecución fluida en dispositivos móviles sin perder precisión temporal.
* **Capas Densas (Fully Connected):** Extraen los patrones finales de las características temporales.
* **Capa de Salida (Softmax):** Clasifica la secuencia en una de las clases correspondientes al vocabulario médico de la Lengua de Señas Mexicana.

##  Resultados y Evaluación

El modelo GRU fue evaluado dividiendo el dataset con un split de validación del 30%. El sistema demostró una alta capacidad para generalizar movimientos complejos, obteniendo los siguientes resultados en el vocabulario de primer contacto médico:

| Métrica | Puntuación Promedio | Descripción |
| :--- | :--- | :--- |
| **Accuracy (Precisión)** | **92% - 95%** | Porcentaje de secuencias de video clasificadas correctamente. |
| **Precision** | **0.94** | Proporción de predicciones de señas que fueron correctas. |
| **Recall (Sensibilidad)** | **0.93** | Capacidad del modelo para identificar todas las variaciones de una misma seña. |
| **F1-Score** | **0.93** | Balance perfecto entre precisión y sensibilidad. |

## Creditos
- [@Jetza13](https://github.com/Jetza13) - UI/UX Designer, Front-End Contributor & Documentation Lead
- [@Gavalencia12](https://github.com/Gavalencia12) – Full-Stack Developer (python/Dart), Database Designer  & Documentation Lead
- [@mpegueros](https://github.com/mpegueros) – UI/UX Designer, Front-End Contributor & Documentation Lead
- [@Danaesito](https://github.com/Danaesito) - Back-End, Database Designer & Documentation Lead
- [@Alex-2213](https://github.com/Alex-2213) - UI/UX Designer & Documentation Lead



## Badges
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![OpenCV](https://img.shields.io/badge/opencv-%23white.svg?style=for-the-badge&logo=opencv&logoColor=white)
![TensorFlow](https://img.shields.io/badge/TensorFlow-%23FF6F00.svg?style=for-the-badge&logo=TensorFlow&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
