import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// App name; not translated.
  ///
  /// In en, this message translates to:
  /// **'PetBridge'**
  String get appTitle;

  /// Fallback for any error code without its own text.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get err_UNKNOWN;

  /// No connection, DNS failure or timeout.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get err_NETWORK;

  /// Server rejected the submitted fields.
  ///
  /// In en, this message translates to:
  /// **'Some of the information isn\'t valid. Please check and try again.'**
  String get err_VALIDATION_FAILED;

  /// Server has no config for the chosen login provider.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method isn\'t available right now.'**
  String get err_PROVIDER_NOT_CONFIGURED;

  /// Login refused because the account is disabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get err_ACCOUNT_DISABLED;

  /// Server rate limit hit.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get err_RATE_LIMITED;

  /// Display name of the lone_leopard pet.
  ///
  /// In en, this message translates to:
  /// **'Lone Leopard'**
  String get pet_lone_leopard_name;

  /// One- or two-sentence personality blurb for the lone_leopard pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Quiet and far-sighted. Lone Leopard makes a plan, then sees it through on its own terms.'**
  String get pet_lone_leopard_intro;

  /// Display name of the leader_lion pet.
  ///
  /// In en, this message translates to:
  /// **'Leader Lion'**
  String get pet_leader_lion_name;

  /// One- or two-sentence personality blurb for the leader_lion pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Bold and decisive. Leader Lion sets the direction and gets everyone moving.'**
  String get pet_leader_lion_intro;

  /// Display name of the thinker_owl pet.
  ///
  /// In en, this message translates to:
  /// **'Thinker Owl'**
  String get pet_thinker_owl_name;

  /// One- or two-sentence personality blurb for the thinker_owl pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Curious and logical. Thinker Owl loves asking why and turning ideas over.'**
  String get pet_thinker_owl_intro;

  /// Display name of the clever_fox pet.
  ///
  /// In en, this message translates to:
  /// **'Clever Fox'**
  String get pet_clever_fox_name;

  /// One- or two-sentence personality blurb for the clever_fox pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Quick-witted and playful. Clever Fox always has a new idea or a fun debate ready.'**
  String get pet_clever_fox_intro;

  /// Display name of the guardian_deer pet.
  ///
  /// In en, this message translates to:
  /// **'Guardian Deer'**
  String get pet_guardian_deer_name;

  /// One- or two-sentence personality blurb for the guardian_deer pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Gentle and insightful. Guardian Deer quietly understands what others feel.'**
  String get pet_guardian_deer_intro;

  /// Display name of the guide_dolphin pet.
  ///
  /// In en, this message translates to:
  /// **'Guide Dolphin'**
  String get pet_guide_dolphin_name;

  /// One- or two-sentence personality blurb for the guide_dolphin pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Warm and encouraging. Guide Dolphin brings people together and lifts them up.'**
  String get pet_guide_dolphin_intro;

  /// Display name of the healing_rabbit pet.
  ///
  /// In en, this message translates to:
  /// **'Healing Rabbit'**
  String get pet_healing_rabbit_name;

  /// One- or two-sentence personality blurb for the healing_rabbit pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Kind and dreamy. Healing Rabbit listens closely and makes friends feel safe.'**
  String get pet_healing_rabbit_intro;

  /// Display name of the happy_shiba pet.
  ///
  /// In en, this message translates to:
  /// **'Happy Shiba'**
  String get pet_happy_shiba_name;

  /// One- or two-sentence personality blurb for the happy_shiba pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Cheerful and full of ideas. Happy Shiba turns any day into an adventure.'**
  String get pet_happy_shiba_intro;

  /// Display name of the steady_beaver pet.
  ///
  /// In en, this message translates to:
  /// **'Steady Beaver'**
  String get pet_steady_beaver_name;

  /// One- or two-sentence personality blurb for the steady_beaver pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Reliable and hardworking. Steady Beaver builds things carefully, one step at a time.'**
  String get pet_steady_beaver_intro;

  /// Display name of the order_sheepdog pet.
  ///
  /// In en, this message translates to:
  /// **'Order Sheepdog'**
  String get pet_order_sheepdog_name;

  /// One- or two-sentence personality blurb for the order_sheepdog pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Organized and dependable. Order Sheepdog keeps everyone on track.'**
  String get pet_order_sheepdog_intro;

  /// Display name of the guardian_penguin pet.
  ///
  /// In en, this message translates to:
  /// **'Guardian Penguin'**
  String get pet_guardian_penguin_name;

  /// One- or two-sentence personality blurb for the guardian_penguin pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Loyal and caring. Guardian Penguin remembers the little things that matter.'**
  String get pet_guardian_penguin_intro;

  /// Display name of the warm_otter pet.
  ///
  /// In en, this message translates to:
  /// **'Warm Otter'**
  String get pet_warm_otter_name;

  /// One- or two-sentence personality blurb for the warm_otter pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Friendly and attentive. Warm Otter makes sure no one feels left out.'**
  String get pet_warm_otter_intro;

  /// Display name of the calm_blackcat pet.
  ///
  /// In en, this message translates to:
  /// **'Calm Black Cat'**
  String get pet_calm_blackcat_name;

  /// One- or two-sentence personality blurb for the calm_blackcat pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Cool-headed and handy. Calm Black Cat stays steady and fixes what\'s broken.'**
  String get pet_calm_blackcat_intro;

  /// Display name of the daring_falcon pet.
  ///
  /// In en, this message translates to:
  /// **'Daring Falcon'**
  String get pet_daring_falcon_name;

  /// One- or two-sentence personality blurb for the daring_falcon pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Energetic and fearless. Daring Falcon jumps in first and figures it out on the way.'**
  String get pet_daring_falcon_intro;

  /// Display name of the easygoing_alpaca pet.
  ///
  /// In en, this message translates to:
  /// **'Easygoing Alpaca'**
  String get pet_easygoing_alpaca_name;

  /// One- or two-sentence personality blurb for the easygoing_alpaca pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Relaxed and artistic. Easygoing Alpaca enjoys the moment and notices beauty everywhere.'**
  String get pet_easygoing_alpaca_intro;

  /// Display name of the party_parrot pet.
  ///
  /// In en, this message translates to:
  /// **'Party Parrot'**
  String get pet_party_parrot_name;

  /// One- or two-sentence personality blurb for the party_parrot pet, shown on the onboarding reveal page.
  ///
  /// In en, this message translates to:
  /// **'Lively and fun. Party Parrot brings the energy wherever it goes.'**
  String get pet_party_parrot_intro;

  /// MBTI mini-quiz EI question.
  ///
  /// In en, this message translates to:
  /// **'After a busy week, on the weekend you\'d rather…'**
  String get quiz_ei_prompt;

  /// MBTI mini-quiz EI answer option A.
  ///
  /// In en, this message translates to:
  /// **'Go out with friends and have fun'**
  String get quiz_ei_a;

  /// MBTI mini-quiz EI answer option B.
  ///
  /// In en, this message translates to:
  /// **'Stay in and recharge on your own'**
  String get quiz_ei_b;

  /// MBTI mini-quiz SN question.
  ///
  /// In en, this message translates to:
  /// **'A friend tells you about a new movie. You want to know…'**
  String get quiz_sn_prompt;

  /// MBTI mini-quiz SN answer option A.
  ///
  /// In en, this message translates to:
  /// **'What happens and who\'s in it'**
  String get quiz_sn_a;

  /// MBTI mini-quiz SN answer option B.
  ///
  /// In en, this message translates to:
  /// **'What it\'s trying to say'**
  String get quiz_sn_b;

  /// MBTI mini-quiz TF question.
  ///
  /// In en, this message translates to:
  /// **'A friend made a not-so-great decision and asks you about it. You…'**
  String get quiz_tf_prompt;

  /// MBTI mini-quiz TF answer option A.
  ///
  /// In en, this message translates to:
  /// **'Point out what went wrong'**
  String get quiz_tf_a;

  /// MBTI mini-quiz TF answer option B.
  ///
  /// In en, this message translates to:
  /// **'Look after their feelings first'**
  String get quiz_tf_b;

  /// MBTI mini-quiz JP question.
  ///
  /// In en, this message translates to:
  /// **'When you travel, you usually…'**
  String get quiz_jp_prompt;

  /// MBTI mini-quiz JP answer option A.
  ///
  /// In en, this message translates to:
  /// **'Plan the itinerary ahead'**
  String get quiz_jp_a;

  /// MBTI mini-quiz JP answer option B.
  ///
  /// In en, this message translates to:
  /// **'Decide when you get there'**
  String get quiz_jp_b;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
