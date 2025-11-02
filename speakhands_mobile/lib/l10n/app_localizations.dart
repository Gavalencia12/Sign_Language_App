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

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @section1.
  ///
  /// In en, this message translates to:
  /// **'Section 1'**
  String get section1;

  /// No description provided for @section2.
  ///
  /// In en, this message translates to:
  /// **'Section 2'**
  String get section2;

  /// No description provided for @section3.
  ///
  /// In en, this message translates to:
  /// **'Section 3'**
  String get section3;

  /// No description provided for @section4.
  ///
  /// In en, this message translates to:
  /// **'Section 4'**
  String get section4;

  /// No description provided for @alphabet.
  ///
  /// In en, this message translates to:
  /// **'Alphabet'**
  String get alphabet;

  /// No description provided for @numbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get numbers;

  /// No description provided for @greetings.
  ///
  /// In en, this message translates to:
  /// **'Greetings'**
  String get greetings;

  /// No description provided for @pronouns.
  ///
  /// In en, this message translates to:
  /// **'Pronouns'**
  String get pronouns;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @colors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colors;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get dates;

  /// No description provided for @sentence_structure.
  ///
  /// In en, this message translates to:
  /// **'Sentence Structure'**
  String get sentence_structure;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @negations_affirmations.
  ///
  /// In en, this message translates to:
  /// **'Negations and Affirmations'**
  String get negations_affirmations;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @object.
  ///
  /// In en, this message translates to:
  /// **'Object'**
  String get object;

  /// No description provided for @emotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get emotions;

  /// No description provided for @emergencies.
  ///
  /// In en, this message translates to:
  /// **'Emergencies'**
  String get emergencies;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Hi, Welcome back!'**
  String get welcome_back;

  /// No description provided for @my_progress.
  ///
  /// In en, this message translates to:
  /// **'My progress'**
  String get my_progress;

  /// No description provided for @not_progress_yet.
  ///
  /// In en, this message translates to:
  /// **'Not progress yet,'**
  String get not_progress_yet;

  /// No description provided for @lets_start_learning.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start learning!'**
  String get lets_start_learning;

  /// No description provided for @section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lesson;

  /// No description provided for @describe_alphabet.
  ///
  /// In en, this message translates to:
  /// **'Describe Alphabet'**
  String get describe_alphabet;

  /// No description provided for @started_section_1.
  ///
  /// In en, this message translates to:
  /// **'Started learning section 1!'**
  String get started_section_1;

  /// No description provided for @challenge_of_the_day.
  ///
  /// In en, this message translates to:
  /// **'Challenge of the Day'**
  String get challenge_of_the_day;

  /// No description provided for @complete_lesson.
  ///
  /// In en, this message translates to:
  /// **'Complete the lesson:'**
  String get complete_lesson;

  /// No description provided for @alphabet_title.
  ///
  /// In en, this message translates to:
  /// **'ALPHABET'**
  String get alphabet_title;

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

  /// No description provided for @edit_your_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile'**
  String get edit_your_profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age: '**
  String get age;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @without_phone.
  ///
  /// In en, this message translates to:
  /// **'Without phone'**
  String get without_phone;

  /// No description provided for @birth_date.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birth_date;

  /// No description provided for @without_birth_date.
  ///
  /// In en, this message translates to:
  /// **'Without Birth Date'**
  String get without_birth_date;

  /// No description provided for @my_statistics.
  ///
  /// In en, this message translates to:
  /// **'MY STATISTICS:'**
  String get my_statistics;

  /// No description provided for @your_progress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress:'**
  String get your_progress;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @disability.
  ///
  /// In en, this message translates to:
  /// **'Disability:'**
  String get disability;

  /// No description provided for @without_disability.
  ///
  /// In en, this message translates to:
  /// **'Without Disability'**
  String get without_disability;

  /// No description provided for @about_you.
  ///
  /// In en, this message translates to:
  /// **'About You:'**
  String get about_you;

  /// No description provided for @without_information.
  ///
  /// In en, this message translates to:
  /// **'Without information'**
  String get without_information;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

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
  /// **'Color'**
  String get color;

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

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @qualife.
  ///
  /// In en, this message translates to:
  /// **'Qualife'**
  String get qualife;

  /// No description provided for @login_section.
  ///
  /// In en, this message translates to:
  /// **'The Login'**
  String get login_section;

  /// No description provided for @change_account.
  ///
  /// In en, this message translates to:
  /// **'Change Account'**
  String get change_account;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get log_out;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @home_welcome_with_name.
  ///
  /// In en, this message translates to:
  /// **'Hello {nombre}. Welcome on the Home Screen.'**
  String home_welcome_with_name(Object nombre);

  /// No description provided for @profile_welcome.
  ///
  /// In en, this message translates to:
  /// **'You\'re in your profile. Here you can see your details and settings.'**
  String get profile_welcome;

  /// No description provided for @translate_info.
  ///
  /// In en, this message translates to:
  /// **'Here you can translate your signs.'**
  String get translate_info;

  /// No description provided for @learn_info.
  ///
  /// In en, this message translates to:
  /// **'This is the section to learn sign language.'**
  String get learn_info;

  /// No description provided for @profile_edit_intro.
  ///
  /// In en, this message translates to:
  /// **'You are in the screen to edit your profile. Here you can change your personal information.'**
  String get profile_edit_intro;

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
