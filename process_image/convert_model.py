import tensorflow as tf

# Cargar el modelo entrenado
model = tf.keras.models.load_model('sign_language_model.h5')

# Convertir el modelo a TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Guardar el modelo convertido
with open('sign_language_model.tflite', 'wb') as f:
    f.write(tflite_model)

print("Modelo convertido a TensorFlow Lite con éxito.")
