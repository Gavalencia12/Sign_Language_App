import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get select_language;

  /// No description provided for @len_es.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get len_es;

  /// No description provided for @len_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get len_en;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @dictate.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get dictate;

  /// No description provided for @speakText.
  ///
  /// In en, this message translates to:
  /// **'Speak text'**
  String get speakText;

  /// No description provided for @stopAudio.
  ///
  /// In en, this message translates to:
  /// **'Stop audio'**
  String get stopAudio;

  /// No description provided for @interpreter_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Interpreter'**
  String get interpreter_screen_title;

  /// No description provided for @let_your_sign_be_heard.
  ///
  /// In en, this message translates to:
  /// **'Let your signs be heard'**
  String get let_your_sign_be_heard;

  /// No description provided for @learn_info.
  ///
  /// In en, this message translates to:
  /// **'This is the section to learn sign language.'**
  String get learn_info;

  /// No description provided for @saying.
  ///
  /// In en, this message translates to:
  /// **'Let your hands do the talking'**
  String get saying;

  /// No description provided for @translator_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translator_screen_title;

  /// No description provided for @let_your_hands_speak.
  ///
  /// In en, this message translates to:
  /// **'Let your hands speak'**
  String get let_your_hands_speak;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation:'**
  String get translation;

  /// No description provided for @waiting_prediction.
  ///
  /// In en, this message translates to:
  /// **'Waiting for prediction...'**
  String get waiting_prediction;

  /// No description provided for @predictions_paused.
  ///
  /// In en, this message translates to:
  /// **'Predictions paused'**
  String get predictions_paused;

  /// No description provided for @camera_not_active.
  ///
  /// In en, this message translates to:
  /// **'Camera not active'**
  String get camera_not_active;

  /// Shows the detected letter
  ///
  /// In en, this message translates to:
  /// **'Detected letter: {letter}'**
  String detected_letter(Object letter);

  /// No description provided for @no_hand_detected.
  ///
  /// In en, this message translates to:
  /// **'No hand detected'**
  String get no_hand_detected;

  /// No description provided for @camera_toggle_on.
  ///
  /// In en, this message translates to:
  /// **'Camera turned ON'**
  String get camera_toggle_on;

  /// No description provided for @camera_toggle_off.
  ///
  /// In en, this message translates to:
  /// **'Camera turned OFF'**
  String get camera_toggle_off;

  /// No description provided for @reset_message.
  ///
  /// In en, this message translates to:
  /// **'Resetting translation'**
  String get reset_message;

  /// No description provided for @pause_explanation.
  ///
  /// In en, this message translates to:
  /// **'Pausing translation'**
  String get pause_explanation;

  /// No description provided for @screen_intro.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the translator screen'**
  String get screen_intro;

  /// No description provided for @subtitle_intro.
  ///
  /// In en, this message translates to:
  /// **'Show your hands to the camera'**
  String get subtitle_intro;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @account_section.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account_section;

  /// No description provided for @personal_data.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personal_data;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @accessibility_section.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility_section;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get color;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Current Theme: Dark'**
  String get dark_mode;

  /// No description provided for @sure_mode.
  ///
  /// In en, this message translates to:
  /// **'Current Theme: Light'**
  String get sure_mode;

  /// No description provided for @sistem_mode.
  ///
  /// In en, this message translates to:
  /// **'Current Theme: System'**
  String get sistem_mode;

  /// No description provided for @select_theme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get select_theme;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'Predetermined by System'**
  String get system;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @help_information_section.
  ///
  /// In en, this message translates to:
  /// **'Help & Information'**
  String get help_information_section;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_and_conditions;

  /// No description provided for @qualife.
  ///
  /// In en, this message translates to:
  /// **'Qualife'**
  String get qualife;

  /// No description provided for @speech_text.
  ///
  /// In en, this message translates to:
  /// **'Speech for text'**
  String get speech_text;

  /// No description provided for @download_tittle.
  ///
  /// In en, this message translates to:
  /// **'Download files to use in offline mode'**
  String get download_tittle;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @download_information.
  ///
  /// In en, this message translates to:
  /// **'Download videos and images for offline use'**
  String get download_information;

  /// No description provided for @download_init.
  ///
  /// In en, this message translates to:
  /// **'Starting download...'**
  String get download_init;

  /// No description provided for @download_no_files.
  ///
  /// In en, this message translates to:
  /// **'No files found to download.'**
  String get download_no_files;

  /// No description provided for @download_progress.
  ///
  /// In en, this message translates to:
  /// **'Downloading... {percent}%'**
  String download_progress(String percent);

  /// No description provided for @download_complete.
  ///
  /// In en, this message translates to:
  /// **'Download complete! ({downloaded} files)'**
  String download_complete(String downloaded);

  /// No description provided for @download_error.
  ///
  /// In en, this message translates to:
  /// **'Fatal error: {error}'**
  String download_error(String error);

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @modal_1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the LSM Translator'**
  String get modal_1;

  /// No description provided for @modal_1_text.
  ///
  /// In en, this message translates to:
  /// **'Use the camera to translate your gestures in real time. Make sure you have good lighting.'**
  String get modal_1_text;

  /// No description provided for @modal_2.
  ///
  /// In en, this message translates to:
  /// **'Place your hands inside the camera frame.'**
  String get modal_2;

  /// No description provided for @modal_3.
  ///
  /// In en, this message translates to:
  /// **'Voice translation'**
  String get modal_3;

  /// No description provided for @modla_3_text.
  ///
  /// In en, this message translates to:
  /// **'The system can pronounce the detected letters or words. You can activate or pause it whenever you want.'**
  String get modla_3_text;

  /// No description provided for @modal_1_interpreter.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the LSM Interpreter'**
  String get modal_1_interpreter;

  /// No description provided for @modal_1_interpreter_text.
  ///
  /// In en, this message translates to:
  /// **'Use the text input to get the sign language interpretation in real time. Type clearly.'**
  String get modal_1_interpreter_text;

  /// No description provided for @modal_2_interpreter.
  ///
  /// In en, this message translates to:
  /// **'Type the text you want to interpret.'**
  String get modal_2_interpreter;

  /// No description provided for @modal_3_interpreter.
  ///
  /// In en, this message translates to:
  /// **'Voice interpretation'**
  String get modal_3_interpreter;

  /// No description provided for @modal_3_interpreter_text.
  ///
  /// In en, this message translates to:
  /// **'The system can read aloud the interpreted text. You can activate or pause it whenever you want.'**
  String get modal_3_interpreter_text;

  /// No description provided for @privacy_policy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy_title;

  /// No description provided for @error_loading_data.
  ///
  /// In en, this message translates to:
  /// **'Error loading data. Please try again.'**
  String get error_loading_data;

  /// No description provided for @effective_date.
  ///
  /// In en, this message translates to:
  /// **'May 25, 2025'**
  String get effective_date;

  /// No description provided for @section_1_title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get section_1_title;

  /// No description provided for @section_1_content.
  ///
  /// In en, this message translates to:
  /// **'To translate signs, the app needs access to your device\'s camera. SpeakHands does not store or transmit images, videos, or personal data captured by the camera without your explicit consent. Non-identifiable data about app usage (errors, performance, usage statistics).'**
  String get section_1_content;

  /// No description provided for @section_2_title.
  ///
  /// In en, this message translates to:
  /// **'2. Use of Information'**
  String get section_2_title;

  /// No description provided for @section_2_content.
  ///
  /// In en, this message translates to:
  /// **'The information is used solely to:\n- Recognize gestures and translate them.\n- Improve app performance.\n- Fix bugs or errors.'**
  String get section_2_content;

  /// No description provided for @section_3_title.
  ///
  /// In en, this message translates to:
  /// **'3. Sharing of Information'**
  String get section_3_title;

  /// No description provided for @section_3_content.
  ///
  /// In en, this message translates to:
  /// **'SpeakHands does not share or sell personal data to third parties. No images or user data are uploaded to external servers.'**
  String get section_3_content;

  /// No description provided for @section_4_title.
  ///
  /// In en, this message translates to:
  /// **'4. Permissions'**
  String get section_4_title;

  /// No description provided for @section_4_content.
  ///
  /// In en, this message translates to:
  /// **'The app requests permissions only to use the camera, necessary for basic functionality. You can revoke these permissions at any time from your device settings.'**
  String get section_4_content;

  /// No description provided for @section_5_title.
  ///
  /// In en, this message translates to:
  /// **'5. Minors'**
  String get section_5_title;

  /// No description provided for @section_5_content.
  ///
  /// In en, this message translates to:
  /// **'The app is not intended for use by minors under the age of 13 without the consent of a responsible adult.'**
  String get section_5_content;

  /// No description provided for @section_6_title.
  ///
  /// In en, this message translates to:
  /// **'6. Security'**
  String get section_6_title;

  /// No description provided for @section_6_content.
  ///
  /// In en, this message translates to:
  /// **'We use technical and organizational measures to protect your information from unauthorized access, alteration, or loss.'**
  String get section_6_content;

  /// No description provided for @section_7_title.
  ///
  /// In en, this message translates to:
  /// **'7. User Rights'**
  String get section_7_title;

  /// No description provided for @section_7_content.
  ///
  /// In en, this message translates to:
  /// **'You can:\n- Request the deletion of your data at any time.\n- Access this policy from the app.\n- Contact us for questions or complaints at [languageappsign@gmail.com](mailto:languageappsign@gmail.com).'**
  String get section_7_content;

  /// No description provided for @terms_title.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_title;

  /// No description provided for @terms_section_1_title.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get terms_section_1_title;

  /// No description provided for @terms_section_1_content.
  ///
  /// In en, this message translates to:
  /// **'By downloading, accessing, or using SpeakHands, you agree to these Terms and Conditions in full. If you do not agree, you must not use the application.'**
  String get terms_section_1_content;

  /// No description provided for @terms_section_2_title.
  ///
  /// In en, this message translates to:
  /// **'2. Permitted Use'**
  String get terms_section_2_title;

  /// No description provided for @terms_section_2_content.
  ///
  /// In en, this message translates to:
  /// **'The application is intended solely for personal, educational, or communicative support purposes. You agree not to use it for illegal activities or those infringing on third-party rights. Offensive or discriminatory content generation is prohibited.'**
  String get terms_section_2_content;

  /// No description provided for @terms_section_3_title.
  ///
  /// In en, this message translates to:
  /// **'3. Intellectual Property'**
  String get terms_section_3_title;

  /// No description provided for @terms_section_3_content.
  ///
  /// In en, this message translates to:
  /// **'All copyrights, logos, trademarks, and technologies used in SpeakHands are the property of the development team and are protected by intellectual property laws.'**
  String get terms_section_3_content;

  /// No description provided for @terms_section_4_title.
  ///
  /// In en, this message translates to:
  /// **'4. Service Modifications'**
  String get terms_section_4_title;

  /// No description provided for @terms_section_4_content.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify or temporarily or permanently suspend the service without prior notice. This includes updates, technical, or functionality changes.'**
  String get terms_section_4_content;

  /// No description provided for @terms_section_5_title.
  ///
  /// In en, this message translates to:
  /// **'5. Limitation of Liability'**
  String get terms_section_5_title;

  /// No description provided for @terms_section_5_content.
  ///
  /// In en, this message translates to:
  /// **'SpeakHands is provided \'as is\'. We do not guarantee absolute accuracy in sign interpretation. SpeakHands will not be responsible for direct or indirect damages derived from the use or misuse of the app, including translation errors or misinterpretations.'**
  String get terms_section_5_content;

  /// No description provided for @terms_section_6_title.
  ///
  /// In en, this message translates to:
  /// **'6. Termination of Use'**
  String get terms_section_6_title;

  /// No description provided for @terms_section_6_content.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to suspend access to the app for any user who violates these terms, without prior notice.'**
  String get terms_section_6_content;

  /// No description provided for @help_title.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help_title;

  /// No description provided for @search_questions.
  ///
  /// In en, this message translates to:
  /// **'Search questions...'**
  String get search_questions;

  /// No description provided for @faq_title.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions (FAQ)'**
  String get faq_title;

  /// No description provided for @no_results_found.
  ///
  /// In en, this message translates to:
  /// **'We found no results for your search.'**
  String get no_results_found;

  /// No description provided for @see_more.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get see_more;

  /// No description provided for @need_more_help.
  ///
  /// In en, this message translates to:
  /// **'Need more help? Contact us!'**
  String get need_more_help;

  /// No description provided for @email_app_not_found.
  ///
  /// In en, this message translates to:
  /// **'No email application found.'**
  String get email_app_not_found;

  /// No description provided for @phone_call_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the phone call.'**
  String get phone_call_failed;

  /// No description provided for @faq_q01.
  ///
  /// In en, this message translates to:
  /// **'I can’t open the email link'**
  String get faq_q01;

  /// No description provided for @faq_q01_a1.
  ///
  /// In en, this message translates to:
  /// **'Install and set up an email app (Gmail/Outlook).'**
  String get faq_q01_a1;

  /// No description provided for @faq_q01_a2.
  ///
  /// In en, this message translates to:
  /// **'Settings > Default apps > Email: select your client.'**
  String get faq_q01_a2;

  /// No description provided for @faq_q01_a3.
  ///
  /// In en, this message translates to:
  /// **'Try on a physical device (emulators usually don’t have email).'**
  String get faq_q01_a3;

  /// No description provided for @faq_q02.
  ///
  /// In en, this message translates to:
  /// **'How can I reset my password?'**
  String get faq_q02;

  /// No description provided for @faq_q02_a1.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Account > Reset password.'**
  String get faq_q02_a1;

  /// No description provided for @faq_q02_a2.
  ///
  /// In en, this message translates to:
  /// **'Check your email (spam) for the reset link.'**
  String get faq_q02_a2;

  /// No description provided for @faq_q02_a3.
  ///
  /// In en, this message translates to:
  /// **'If it doesn’t arrive, try again or contact us by email.'**
  String get faq_q02_a3;

  /// No description provided for @faq_q03.
  ///
  /// In en, this message translates to:
  /// **'How do I change my email address?'**
  String get faq_q03;

  /// No description provided for @faq_q03_a1.
  ///
  /// In en, this message translates to:
  /// **'Profile > Personal data > Email.'**
  String get faq_q03_a1;

  /// No description provided for @faq_q03_a2.
  ///
  /// In en, this message translates to:
  /// **'Verify the new email using the link you received.'**
  String get faq_q03_a2;

  /// No description provided for @faq_q03_a3.
  ///
  /// In en, this message translates to:
  /// **'Log out and back in if you don’t see the change.'**
  String get faq_q03_a3;

  /// No description provided for @faq_q04.
  ///
  /// In en, this message translates to:
  /// **'What should I do if I have a technical issue?'**
  String get faq_q04;

  /// No description provided for @faq_q04_a1.
  ///
  /// In en, this message translates to:
  /// **'Close and reopen the app.'**
  String get faq_q04_a1;

  /// No description provided for @faq_q04_a2.
  ///
  /// In en, this message translates to:
  /// **'Restart the device.'**
  String get faq_q04_a2;

  /// No description provided for @faq_q04_a3.
  ///
  /// In en, this message translates to:
  /// **'Update to the latest version available.'**
  String get faq_q04_a3;

  /// No description provided for @faq_q05.
  ///
  /// In en, this message translates to:
  /// **'The camera isn’t working'**
  String get faq_q05;

  /// No description provided for @faq_q05_a1.
  ///
  /// In en, this message translates to:
  /// **'Make sure camera permissions are granted in Settings.'**
  String get faq_q05_a1;

  /// No description provided for @faq_q05_a2.
  ///
  /// In en, this message translates to:
  /// **'Close other apps that may be using the camera.'**
  String get faq_q05_a2;

  /// No description provided for @faq_q05_a3.
  ///
  /// In en, this message translates to:
  /// **'Try restarting the app or device.'**
  String get faq_q05_a3;

  /// No description provided for @faq_q05_a4.
  ///
  /// In en, this message translates to:
  /// **'Make sure the camera is clean and unobstructed.'**
  String get faq_q05_a4;

  /// No description provided for @faq_q06.
  ///
  /// In en, this message translates to:
  /// **'The app is not responding'**
  String get faq_q06;

  /// No description provided for @faq_q06_a1.
  ///
  /// In en, this message translates to:
  /// **'Close and reopen the app.'**
  String get faq_q06_a1;

  /// No description provided for @faq_q06_a2.
  ///
  /// In en, this message translates to:
  /// **'Restart your device.'**
  String get faq_q06_a2;

  /// No description provided for @faq_q06_a3.
  ///
  /// In en, this message translates to:
  /// **'Check that you have the latest app version installed.'**
  String get faq_q06_a3;

  /// No description provided for @faq_q06_a4.
  ///
  /// In en, this message translates to:
  /// **'If it persists, try uninstalling and reinstalling the app.'**
  String get faq_q06_a4;

  /// No description provided for @faq_q07.
  ///
  /// In en, this message translates to:
  /// **'The app doesn’t detect hands'**
  String get faq_q07;

  /// No description provided for @faq_q07_a1.
  ///
  /// In en, this message translates to:
  /// **'Make sure you’re in a well-lit place.'**
  String get faq_q07_a1;

  /// No description provided for @faq_q07_a2.
  ///
  /// In en, this message translates to:
  /// **'Keep your hands within the camera frame.'**
  String get faq_q07_a2;

  /// No description provided for @faq_q07_a3.
  ///
  /// In en, this message translates to:
  /// **'Avoid busy backgrounds that may interfere with detection.'**
  String get faq_q07_a3;

  /// No description provided for @faq_q07_a4.
  ///
  /// In en, this message translates to:
  /// **'Ensure the camera is clean.'**
  String get faq_q07_a4;

  /// No description provided for @faq_q08.
  ///
  /// In en, this message translates to:
  /// **'The translation is incorrect'**
  String get faq_q08;

  /// No description provided for @faq_q08_a1.
  ///
  /// In en, this message translates to:
  /// **'Make sure your hand is positioned correctly within the frame.'**
  String get faq_q08_a1;

  /// No description provided for @faq_q08_a2.
  ///
  /// In en, this message translates to:
  /// **'Check that lighting is sufficient for the camera to detect signs.'**
  String get faq_q08_a2;

  /// No description provided for @faq_q08_a3.
  ///
  /// In en, this message translates to:
  /// **'Try moving your hand more slowly for better detection.'**
  String get faq_q08_a3;

  /// No description provided for @faq_q08_a4.
  ///
  /// In en, this message translates to:
  /// **'If it persists, try restarting the app.'**
  String get faq_q08_a4;

  /// No description provided for @faq_q09.
  ///
  /// In en, this message translates to:
  /// **'The app closes unexpectedly'**
  String get faq_q09;

  /// No description provided for @faq_q09_a1.
  ///
  /// In en, this message translates to:
  /// **'Ensure you have enough storage space.'**
  String get faq_q09_a1;

  /// No description provided for @faq_q09_a2.
  ///
  /// In en, this message translates to:
  /// **'Restart your device to free memory.'**
  String get faq_q09_a2;

  /// No description provided for @faq_q09_a3.
  ///
  /// In en, this message translates to:
  /// **'If it persists, uninstall and reinstall the app.'**
  String get faq_q09_a3;

  /// No description provided for @faq_q09_a4.
  ///
  /// In en, this message translates to:
  /// **'Verify the app is updated to the latest version.'**
  String get faq_q09_a4;

  /// No description provided for @faq_q10.
  ///
  /// In en, this message translates to:
  /// **'The app can’t connect to the Internet'**
  String get faq_q10;

  /// No description provided for @faq_q10_a1.
  ///
  /// In en, this message translates to:
  /// **'Check your Internet connection (Wi-Fi or mobile data).'**
  String get faq_q10_a1;

  /// No description provided for @faq_q10_a2.
  ///
  /// In en, this message translates to:
  /// **'Restart your router or device if connection issues continue.'**
  String get faq_q10_a2;

  /// No description provided for @faq_q10_a3.
  ///
  /// In en, this message translates to:
  /// **'Verify the app has permission to access the Internet.'**
  String get faq_q10_a3;

  /// No description provided for @faq_q10_a4.
  ///
  /// In en, this message translates to:
  /// **'Toggle Wi-Fi or mobile data off and on again.'**
  String get faq_q10_a4;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
