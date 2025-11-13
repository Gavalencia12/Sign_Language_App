// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get select_language => 'Select a language';

  @override
  String get len_es => 'Spanish';

  @override
  String get len_en => 'English';

  @override
  String get clear => 'Clear';

  @override
  String get dictate => 'Dictate';

  @override
  String get speakText => 'Speak text';

  @override
  String get stopAudio => 'Stop audio';

  @override
  String get interpreter_screen_title => 'Interpreter';

  @override
  String get let_your_sign_be_heard => 'Let your signs be heard';

  @override
  String get learn_info => 'This is the section to learn sign language.';

  @override
  String get saying => 'Let your hands do the talking';

  @override
  String get translator_screen_title => 'Translate';

  @override
  String get let_your_hands_speak => 'Let your hands speak';

  @override
  String get translation => 'Translation:';

  @override
  String get waiting_prediction => 'Waiting for prediction...';

  @override
  String get predictions_paused => 'Predictions paused';

  @override
  String get camera_not_active => 'Camera not active';

  @override
  String get refresh => 'Refresh';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String detected_letter(Object letter) {
    return 'Detected letter: $letter';
  }

  @override
  String get no_hand_detected => 'No hand detected';

  @override
  String get camera_toggle_on => 'Camera turned ON';

  @override
  String get camera_toggle_off => 'Camera turned OFF';

  @override
  String get reset_message => 'Resetting translation';

  @override
  String get pause_explanation => 'Pausing translation';

  @override
  String get screen_intro => 'Welcome to the translator screen';

  @override
  String get subtitle_intro => 'Show your hands to the camera';

  @override
  String get settings_title => 'Settings';

  @override
  String get account_section => 'Account';

  @override
  String get personal_data => 'Personal Data';

  @override
  String get account => 'Account';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get accessibility_section => 'Accessibility';

  @override
  String get language => 'Language';

  @override
  String get color => 'Appearance';

  @override
  String get dark_mode => 'Current Theme: Dark';

  @override
  String get sure_mode => 'Current Theme: Light';

  @override
  String get sistem_mode => 'Current Theme: System';

  @override
  String get select_theme => 'Select Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get system => 'Predetermined by System';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get help_information_section => 'Help & Information';

  @override
  String get terms_and_conditions => 'Terms and Conditions';

  @override
  String get qualife => 'Qualife';

  @override
  String get speech_text => 'Speech for text';

  @override
  String get download_tittle => 'Download files to use in offline mode';

  @override
  String get download => 'Download';

  @override
  String get download_information => 'Download videos and images for offline use';

  @override
  String get download_init => 'Starting download...';

  @override
  String get download_no_files => 'No files found to download.';

  @override
  String download_progress(String percent) {
    return 'Downloading... $percent%';
  }

  @override
  String download_complete(String downloaded) {
    return 'Download complete! ($downloaded files)';
  }

  @override
  String download_error(String error) {
    return 'Fatal error: $error';
  }

  @override
  String get hello => 'Hello';

  @override
  String get show => 'Show';

  @override
  String get modal_1 => 'Welcome to the LSM Translator';

  @override
  String get modal_1_text => 'Use the camera to translate your gestures in real time. Make sure you have good lighting.';

  @override
  String get modal_2 => 'Place your hands inside the camera frame.';

  @override
  String get modal_3 => 'Voice translation';

  @override
  String get modla_3_text => 'The system can pronounce the detected letters or words. You can activate or pause it whenever you want.';

  @override
  String get modal_1_interpreter => 'Welcome to the LSM Interpreter';

  @override
  String get modal_1_interpreter_text => 'Use the text input to get the sign language interpretation in real time. Type clearly.';

  @override
  String get modal_2_interpreter => 'Type the text you want to interpret.';

  @override
  String get modal_3_interpreter => 'Voice interpretation';

  @override
  String get modal_3_interpreter_text => 'The system can read aloud the interpreted text. You can activate or pause it whenever you want.';

  @override
  String get privacy_policy_title => 'Privacy Policy';

  @override
  String get error_loading_data => 'Error loading data. Please try again.';

  @override
  String get effective_date => 'May 25, 2025';

  @override
  String get section_1_title => '1. Information We Collect';

  @override
  String get section_1_content => 'To translate signs, the app needs access to your device\'s camera. SpeakHands does not store or transmit images, videos, or personal data captured by the camera without your explicit consent. Non-identifiable data about app usage (errors, performance, usage statistics).';

  @override
  String get section_2_title => '2. Use of Information';

  @override
  String get section_2_content => 'The information is used solely to:\n- Recognize gestures and translate them.\n- Improve app performance.\n- Fix bugs or errors.';

  @override
  String get section_3_title => '3. Sharing of Information';

  @override
  String get section_3_content => 'SpeakHands does not share or sell personal data to third parties. No images or user data are uploaded to external servers.';

  @override
  String get section_4_title => '4. Permissions';

  @override
  String get section_4_content => 'The app requests permissions only to use the camera, necessary for basic functionality. You can revoke these permissions at any time from your device settings.';

  @override
  String get section_5_title => '5. Minors';

  @override
  String get section_5_content => 'The app is not intended for use by minors under the age of 13 without the consent of a responsible adult.';

  @override
  String get section_6_title => '6. Security';

  @override
  String get section_6_content => 'We use technical and organizational measures to protect your information from unauthorized access, alteration, or loss.';

  @override
  String get section_7_title => '7. User Rights';

  @override
  String get section_7_content => 'You can:\n- Request the deletion of your data at any time.\n- Access this policy from the app.\n- Contact us for questions or complaints at [languageappsign@gmail.com](mailto:languageappsign@gmail.com).';

  @override
  String get terms_title => 'Terms and Conditions';

  @override
  String get terms_section_1_title => '1. Acceptance of Terms';

  @override
  String get terms_section_1_content => 'By downloading, accessing, or using SpeakHands, you agree to these Terms and Conditions in full. If you do not agree, you must not use the application.';

  @override
  String get terms_section_2_title => '2. Permitted Use';

  @override
  String get terms_section_2_content => 'The application is intended solely for personal, educational, or communicative support purposes. You agree not to use it for illegal activities or those infringing on third-party rights. Offensive or discriminatory content generation is prohibited.';

  @override
  String get terms_section_3_title => '3. Intellectual Property';

  @override
  String get terms_section_3_content => 'All copyrights, logos, trademarks, and technologies used in SpeakHands are the property of the development team and are protected by intellectual property laws.';

  @override
  String get terms_section_4_title => '4. Service Modifications';

  @override
  String get terms_section_4_content => 'We reserve the right to modify or temporarily or permanently suspend the service without prior notice. This includes updates, technical, or functionality changes.';

  @override
  String get terms_section_5_title => '5. Limitation of Liability';

  @override
  String get terms_section_5_content => 'SpeakHands is provided \'as is\'. We do not guarantee absolute accuracy in sign interpretation. SpeakHands will not be responsible for direct or indirect damages derived from the use or misuse of the app, including translation errors or misinterpretations.';

  @override
  String get terms_section_6_title => '6. Termination of Use';

  @override
  String get terms_section_6_content => 'We reserve the right to suspend access to the app for any user who violates these terms, without prior notice.';

  @override
  String get help_title => 'Help';

  @override
  String get search_questions => 'Search questions...';

  @override
  String get faq_title => 'Frequently Asked Questions (FAQ)';

  @override
  String get no_results_found => 'We found no results for your search.';

  @override
  String get see_more => 'See more';

  @override
  String get need_more_help => 'Need more help? Contact us!';

  @override
  String get email_app_not_found => 'No email application found.';

  @override
  String get phone_call_failed => 'Could not start the phone call.';

  @override
  String get faq_q01 => 'I can’t open the email link';

  @override
  String get faq_q01_a1 => 'Install and set up an email app (Gmail/Outlook).';

  @override
  String get faq_q01_a2 => 'Settings > Default apps > Email: select your client.';

  @override
  String get faq_q01_a3 => 'Try on a physical device (emulators usually don’t have email).';

  @override
  String get faq_q02 => 'How can I reset my password?';

  @override
  String get faq_q02_a1 => 'Go to Profile > Account > Reset password.';

  @override
  String get faq_q02_a2 => 'Check your email (spam) for the reset link.';

  @override
  String get faq_q02_a3 => 'If it doesn’t arrive, try again or contact us by email.';

  @override
  String get faq_q03 => 'How do I change my email address?';

  @override
  String get faq_q03_a1 => 'Profile > Personal data > Email.';

  @override
  String get faq_q03_a2 => 'Verify the new email using the link you received.';

  @override
  String get faq_q03_a3 => 'Log out and back in if you don’t see the change.';

  @override
  String get faq_q04 => 'What should I do if I have a technical issue?';

  @override
  String get faq_q04_a1 => 'Close and reopen the app.';

  @override
  String get faq_q04_a2 => 'Restart the device.';

  @override
  String get faq_q04_a3 => 'Update to the latest version available.';

  @override
  String get faq_q05 => 'The camera isn’t working';

  @override
  String get faq_q05_a1 => 'Make sure camera permissions are granted in Settings.';

  @override
  String get faq_q05_a2 => 'Close other apps that may be using the camera.';

  @override
  String get faq_q05_a3 => 'Try restarting the app or device.';

  @override
  String get faq_q05_a4 => 'Make sure the camera is clean and unobstructed.';

  @override
  String get faq_q06 => 'The app is not responding';

  @override
  String get faq_q06_a1 => 'Close and reopen the app.';

  @override
  String get faq_q06_a2 => 'Restart your device.';

  @override
  String get faq_q06_a3 => 'Check that you have the latest app version installed.';

  @override
  String get faq_q06_a4 => 'If it persists, try uninstalling and reinstalling the app.';

  @override
  String get faq_q07 => 'The app doesn’t detect hands';

  @override
  String get faq_q07_a1 => 'Make sure you’re in a well-lit place.';

  @override
  String get faq_q07_a2 => 'Keep your hands within the camera frame.';

  @override
  String get faq_q07_a3 => 'Avoid busy backgrounds that may interfere with detection.';

  @override
  String get faq_q07_a4 => 'Ensure the camera is clean.';

  @override
  String get faq_q08 => 'The translation is incorrect';

  @override
  String get faq_q08_a1 => 'Make sure your hand is positioned correctly within the frame.';

  @override
  String get faq_q08_a2 => 'Check that lighting is sufficient for the camera to detect signs.';

  @override
  String get faq_q08_a3 => 'Try moving your hand more slowly for better detection.';

  @override
  String get faq_q08_a4 => 'If it persists, try restarting the app.';

  @override
  String get faq_q09 => 'The app closes unexpectedly';

  @override
  String get faq_q09_a1 => 'Ensure you have enough storage space.';

  @override
  String get faq_q09_a2 => 'Restart your device to free memory.';

  @override
  String get faq_q09_a3 => 'If it persists, uninstall and reinstall the app.';

  @override
  String get faq_q09_a4 => 'Verify the app is updated to the latest version.';

  @override
  String get faq_q10 => 'The app can’t connect to the Internet';

  @override
  String get faq_q10_a1 => 'Check your Internet connection (Wi-Fi or mobile data).';

  @override
  String get faq_q10_a2 => 'Restart your router or device if connection issues continue.';

  @override
  String get faq_q10_a3 => 'Verify the app has permission to access the Internet.';

  @override
  String get faq_q10_a4 => 'Toggle Wi-Fi or mobile data off and on again.';
}
