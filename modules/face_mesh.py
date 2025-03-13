import cv2
import numpy as np
import mediapipe as mp

mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(max_num_faces=1)

def process_face(frame, frame_rgb):
    face_results = face_mesh.process(frame_rgb)
    if face_results.multi_face_landmarks:
        for face_landmarks in face_results.multi_face_landmarks:
            h, w, _ = frame.shape

            face_contour = [
                10, 338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288, 397, 
                365, 379, 378, 400, 377, 152, 148, 176, 149, 150, 136, 172, 58, 
                132, 93, 234, 127, 162, 21, 54, 103, 67, 109
            ]

            face_points = [(int(face_landmarks.landmark[i].x * w), int(face_landmarks.landmark[i].y * h)) for i in face_contour]
            cv2.polylines(frame, [np.array(face_points, np.int32)], isClosed=True, color=(255, 255, 255), thickness=1)
            
            for point in face_points:
                cv2.circle(frame, point, 3, (0, 0, 0), -1)

            # Contorno de los ojos
            left_eye = [133, 173, 157, 158, 159, 160, 161, 246, 33, 7, 163, 144, 145, 153, 154, 155]  # Contorno ojo izquierdo
            right_eye = [362, 398, 384, 385, 386, 387, 388, 466, 263, 249, 373, 362, 380, 381, 382, 362]  # Contorno ojo derecho
            
            left_eye_points = [(int(face_landmarks.landmark[i].x * w), int(face_landmarks.landmark[i].y * h)) for i in left_eye]
            right_eye_points = [(int(face_landmarks.landmark[i].x * w), int(face_landmarks.landmark[i].y * h)) for i in right_eye]
            
            # Dibujar contorno de los ojos
            cv2.polylines(frame, [np.array(left_eye_points, np.int32)], isClosed=True, color=(255, 255, 255), thickness=1)  # Azul
            cv2.polylines(frame, [np.array(right_eye_points, np.int32)], isClosed=True, color=(255, 255, 255), thickness=1)  # Azul
            for point in left_eye_points:
                cv2.circle(frame, point, 1, (0, 0, 255), -2)  
            for point in right_eye_points:
                cv2.circle(frame, point, 1, (0, 0, 255), -2) 
    
    return frame
