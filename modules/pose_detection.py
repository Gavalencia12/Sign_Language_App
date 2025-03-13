import cv2
import mediapipe as mp

mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
pose = mp_pose.Pose()

def process_pose(frame, frame_rgb):
    pose_results = pose.process(frame_rgb)
    if pose_results.pose_landmarks:
        h, w, _ = frame.shape
        
        left_shoulder = pose_results.pose_landmarks.landmark[11]
        right_shoulder = pose_results.pose_landmarks.landmark[12]

        left_shoulder_y = int(left_shoulder.y * h)
        right_shoulder_y = int(right_shoulder.y * h)

        left_shoulder_coord = (int(left_shoulder.x * w), left_shoulder_y)
        right_shoulder_coord = (int(right_shoulder.x * w), right_shoulder_y)
        
        cv2.circle(frame, left_shoulder_coord, 5, (0, 255, 0), -1)
        cv2.circle(frame, right_shoulder_coord, 5, (0, 255, 0), -1)
        cv2.line(frame, left_shoulder_coord, right_shoulder_coord, (255, 255, 255), 2)

        diff = left_shoulder_y - right_shoulder_y

        if abs(diff) > 20:
            if diff > 0:
                text = "Inclinado a la derecha"
            else:
                text = "Inclinado a la izquierda"
        else:
            text = "Cuerpo recto"

        cv2.putText(frame, text, (30, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
    
    return frame
