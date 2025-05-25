//text to the home screen
class SpeechTexts {
  static String homeWelcome(String nombre) =>
      "Hello $nombre. Welcome to the home screen.";

  static const String profileWelcome = "Estás en tu perfil.";
  static const String translateInfo = "Aquí puedes traducir tus señas.";
  static const String learnInfo = "Esta es la sección para aprender lengua de señas.";
}

// text to the translator screen
class TranslatorSpeechTexts {
  static const String screenTitle = "You're in the translator screen.";
  static const String subtitle = "Let your hands speak.";
  static const String cameraOff = "The camera is currently off.";
  static const String cameraToggleOn = "Camera turned on.";
  static const String cameraToggleOff = "Camera turned off.";
  static const String resetMessage = "Prediction has been reset.";
  static const String pauseExplanation = "Press this to take a prediction snapshot.";
  static const String waitingPrediction = "Waiting for prediction.";
  static const String noHandDetected = "No hand detected, please try again.";
  static String detectedLetter(String letter) => "Detected letter: Letter $letter";
}

class LearnSpeechTexts {
  static const String intro = "This is the section to learn sign language.";
}

class ProfileSpeechTexts {
  static const String intro = "You're in your profile. Here you can see your details and settings.";
}
class SettingsSpeechTexts {
  static const String intro = "You're in the settings section. Here you can adjust your preferences.";
  static const String themeToggleOn = "Dark mode activated.";
  static const String themeToggleOff = "Light mode activated.";
  static const String languageChange = "Language changed to Spanish.";
}
