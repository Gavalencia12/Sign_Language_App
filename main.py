import cv2
import numpy as np
import mediapipe as mp
from modules.hand_tracking import process_hands
from modules.face_mesh import process_face
from modules.pose_detection import process_pose
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), "modules"))


cap = cv2.VideoCapture(0) #activar la camara
if not cap.isOpened():
    print("No se pudo acceder a la cámara.")
    exit()


while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Convertir el frame a RGB "BGR"
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    # Procesar las manos
    frame = process_hands(frame, frame_rgb)
    
    # Procesar la cara
    frame = process_face(frame, frame_rgb)
    
    # Procesar la pose
    frame = process_pose(frame, frame_rgb)
    


    # Mostrar el frame
    cv2.imshow('TRANSMAE', frame)
    if cv2.waitKey(1) & 0xFF == ord('q') :
        break

cap.release()
cv2.destroyAllWindows()