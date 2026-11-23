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

  /// 503 NOT_READY: the server or a login provider is briefly unavailable; retrying later works.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Please try again in a moment.'**
  String get err_NOT_READY;

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

  /// Apple sign-in is not available yet.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple isn\'t available yet.'**
  String get err_APPLE_LOGIN_UNAVAILABLE;

  /// Google sign-in failed on the device (not a cancel).
  ///
  /// In en, this message translates to:
  /// **'Google sign-in didn\'t work. Please try again.'**
  String get err_GOOGLE_SIGN_IN_FAILED;

  /// Primary button to go to the next step.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// Button to try a failed action again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_retry;

  /// Log out button.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get common_logout;

  /// Google sign-in button on the login page.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get login_google;

  /// Apple sign-in button on the login page.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get login_apple;

  /// Snackbar when the Apple button is tapped but Apple sign-in is off.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple is coming soon.'**
  String get login_apple_coming_soon;

  /// Divider label above the developer email login (dev builds only).
  ///
  /// In en, this message translates to:
  /// **'Developer login (dev only)'**
  String get login_dev_title;

  /// Label of the developer login email field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get login_dev_email_label;

  /// Button that logs in with the developer email.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login_dev_submit;

  /// Onboarding app bar: current step of total.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onb_progress(int step, int total);

  /// Onboarding step 1 title: pick your language.
  ///
  /// In en, this message translates to:
  /// **'What\'s your language?'**
  String get onb_lang_title;

  /// Explains that the chosen language is used for the UI and translations.
  ///
  /// In en, this message translates to:
  /// **'The app will use it, and your friends\' messages will be translated into it.'**
  String get onb_lang_hint;

  /// Onboarding step 2 title: pick your MBTI type.
  ///
  /// In en, this message translates to:
  /// **'What\'s your MBTI type?'**
  String get onb_mbti_title;

  /// Link to the 4-question quiz for users who do not know their type.
  ///
  /// In en, this message translates to:
  /// **'I\'m not sure — take a quick quiz'**
  String get onb_mbti_not_sure;

  /// Quiz page title: question n of total.
  ///
  /// In en, this message translates to:
  /// **'Question {n} of {total}'**
  String onb_quiz_progress(int n, int total);

  /// Quiz result page title.
  ///
  /// In en, this message translates to:
  /// **'Your type'**
  String get onb_quiz_result_title;

  /// Tells the user they can tap a letter to flip it.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t feel right? Tap a letter to switch it.'**
  String get onb_quiz_result_hint;

  /// Confirms the quiz result as the MBTI type.
  ///
  /// In en, this message translates to:
  /// **'Use this type'**
  String get onb_quiz_result_confirm;

  /// Onboarding step 3 title: the pet for your type.
  ///
  /// In en, this message translates to:
  /// **'Meet your pet'**
  String get onb_reveal_title;

  /// Onboarding step 4 title: nickname and age.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get onb_profile_title;

  /// Nickname field label.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get onb_nickname_label;

  /// Helper text under the nickname field.
  ///
  /// In en, this message translates to:
  /// **'1–20 characters'**
  String get onb_nickname_hint;

  /// Nickname is empty after trimming.
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname.'**
  String get onb_nickname_err_empty;

  /// Nickname is over 20 characters.
  ///
  /// In en, this message translates to:
  /// **'Nickname can be at most 20 characters.'**
  String get onb_nickname_err_too_long;

  /// Nickname has control characters.
  ///
  /// In en, this message translates to:
  /// **'Nickname contains characters that are not allowed.'**
  String get onb_nickname_err_invalid;

  /// Server rejected the nickname (VALIDATION_FAILED on nickname).
  ///
  /// In en, this message translates to:
  /// **'This nickname can\'t be used. Please try another one.'**
  String get onb_nickname_err_server;

  /// Server rejected this field (VALIDATION_FAILED).
  ///
  /// In en, this message translates to:
  /// **'Please check this.'**
  String get onb_field_invalid;

  /// Age section label.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onb_age_label;

  /// Age choice: under 13.
  ///
  /// In en, this message translates to:
  /// **'Under 13'**
  String get onb_age_under13;

  /// Age choice: 13 to 17.
  ///
  /// In en, this message translates to:
  /// **'13–17'**
  String get onb_age_teen;

  /// Age choice: 18 or older.
  ///
  /// In en, this message translates to:
  /// **'18 or older'**
  String get onb_age_adult;

  /// Submits onboarding.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onb_submit;

  /// Title of the page for users under 13.
  ///
  /// In en, this message translates to:
  /// **'Sorry, you can\'t use PetBridge yet'**
  String get onb_too_young_title;

  /// Explains the age limit to users under 13.
  ///
  /// In en, this message translates to:
  /// **'PetBridge is for people aged 13 and over. We hope to see you when you\'re older!'**
  String get onb_too_young_body;

  /// Home tab 1: the shared room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get home_tab_room;

  /// Home tab 2: chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get home_tab_chat;

  /// Home tab 3: backpack / inventory.
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get home_tab_bag;

  /// Home tab 4: my profile.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get home_tab_me;

  /// Placeholder text on tabs that are not built yet.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get home_coming_soon;

  /// Me tab row label: nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get me_nickname;

  /// Me tab row label: MBTI type.
  ///
  /// In en, this message translates to:
  /// **'MBTI'**
  String get me_mbti;

  /// Me tab row label: pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get me_pet;

  /// Join code cannot be used (reason deliberately not given).
  ///
  /// In en, this message translates to:
  /// **'This code is invalid or no longer works.'**
  String get err_CODE_INVALID;

  /// Join refused: room full.
  ///
  /// In en, this message translates to:
  /// **'This room is already full.'**
  String get err_ROOM_FULL;

  /// Join refused: already a member.
  ///
  /// In en, this message translates to:
  /// **'You\'re already in this room.'**
  String get err_ALREADY_MEMBER;

  /// Join refused: age groups differ.
  ///
  /// In en, this message translates to:
  /// **'Minors and adults can\'t share a room.'**
  String get err_AGE_RESTRICTED;

  /// Join refused: in 2 rooms already.
  ///
  /// In en, this message translates to:
  /// **'You\'re already in 2 rooms. Leave one first.'**
  String get err_ROOM_LIMIT;

  /// Too many wrong codes; generic text when no countdown is shown.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get err_CODE_COOLDOWN;

  /// Action needs completed onboarding.
  ///
  /// In en, this message translates to:
  /// **'Please finish signing up first.'**
  String get err_ONBOARDING_REQUIRED;

  /// Code regeneration refused; generic text.
  ///
  /// In en, this message translates to:
  /// **'Can\'t create a code right now.'**
  String get err_CODE_ISSUE_LIMIT;

  /// Owner-only action refused; shown to a non-owner.
  ///
  /// In en, this message translates to:
  /// **'You\'re not the owner of this room.'**
  String get err_NOT_ROOM_OWNER;

  /// Owner tried to leave their own room.
  ///
  /// In en, this message translates to:
  /// **'The owner can\'t leave their own room. Dissolve it from the manage page instead.'**
  String get err_OWNER_CANNOT_LEAVE;

  /// The room is gone (dissolved or never joined).
  ///
  /// In en, this message translates to:
  /// **'This room no longer exists.'**
  String get err_ROOM_NOT_FOUND;

  /// Title of the user's own room.
  ///
  /// In en, this message translates to:
  /// **'My room'**
  String get room_title_mine;

  /// Title of someone else's room, named after its owner.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s room'**
  String room_title_of(String name);

  /// Title of someone else's room when the owner has no nickname.
  ///
  /// In en, this message translates to:
  /// **'A friend\'s room'**
  String get room_title_friend;

  /// Members over capacity.
  ///
  /// In en, this message translates to:
  /// **'{count}/{capacity}'**
  String room_count(int count, int capacity);

  /// Button to the backpack to share a code.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get room_invite;

  /// Opens the join page.
  ///
  /// In en, this message translates to:
  /// **'Enter a code'**
  String get room_join_button;

  /// Solo state card under the room scene: the user is alone in their own room.
  ///
  /// In en, this message translates to:
  /// **'You\'re the only one here. Invite friends, or use a code to visit a friend\'s room.'**
  String get room_solo_card;

  /// Label on an empty seat in the user's own room; opens the backpack to share a code.
  ///
  /// In en, this message translates to:
  /// **'+ Invite'**
  String get room_seat_invite;

  /// Pill shown while the realtime connection has been down for a few seconds.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get room_reconnecting;

  /// Join page app bar title
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get join_title;

  /// Join page explanation above the code field
  ///
  /// In en, this message translates to:
  /// **'Enter the 8-character code a friend shared with you'**
  String get join_hint;

  /// Button that pastes the clipboard into the code field
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get join_paste;

  /// Join page submit button
  ///
  /// In en, this message translates to:
  /// **'Join room'**
  String get join_submit;

  /// Cooldown message; time is mm:ss
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Try again in {time}'**
  String join_retry_in(String time);

  /// Button that opens the joined room in the room tab
  ///
  /// In en, this message translates to:
  /// **'Go to room'**
  String get join_go_room;

  /// Join success title
  ///
  /// In en, this message translates to:
  /// **'Welcome in!'**
  String get join_success_title;

  /// Join success body; room is a room title such as Hikari's room
  ///
  /// In en, this message translates to:
  /// **'You joined {room}'**
  String join_success_body(String room);

  /// Reward card title on the join success page
  ///
  /// In en, this message translates to:
  /// **'A gift for you'**
  String get join_reward_title;

  /// Reward card explanation
  ///
  /// In en, this message translates to:
  /// **'Share it with friends so they can move into your room'**
  String get join_reward_body;

  /// Button that opens the share page for the first reward code
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get join_share;

  /// Backpack tab app bar title
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get bag_title;

  /// Backpack app bar action that opens the join page
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get bag_join;

  /// Code status label
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get bag_status_unused;

  /// Code status label
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get bag_status_used;

  /// Code status label
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get bag_status_expired;

  /// Code status label (room filled or dissolved)
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get bag_status_void;

  /// Current size of the room a code belongs to
  ///
  /// In en, this message translates to:
  /// **'Room {count}/{capacity}'**
  String bag_room_count(int count, int capacity);

  /// Validity left on an unused code, one day or more
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day left} other{{days} days left}}'**
  String bag_days_left(int days);

  /// Validity left on an unused code, under a day
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour left} other{{hours} hours left}}'**
  String bag_hours_left(int hours);

  /// Validity left on an unused code, under an hour
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get bag_expiring;

  /// Share button on an unused code
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get bag_share;

  /// Button that issues a new code for the user's own room
  ///
  /// In en, this message translates to:
  /// **'Generate code'**
  String get bag_regen;

  /// Hint under a disabled generate button when the own room is full
  ///
  /// In en, this message translates to:
  /// **'Your room is full. Free up a seat first.'**
  String get bag_regen_full;

  /// Generations left today
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You can generate 1 more today} other{You can generate {count} more today}}'**
  String bag_regen_remaining(int count);

  /// Hint when no generations are left today
  ///
  /// In en, this message translates to:
  /// **'No generations left today'**
  String get bag_regen_none_left;

  /// SnackBar after generating a code
  ///
  /// In en, this message translates to:
  /// **'New code generated'**
  String get bag_regen_done;

  /// Empty backpack
  ///
  /// In en, this message translates to:
  /// **'No codes yet'**
  String get bag_empty;

  /// Generate refused: room full
  ///
  /// In en, this message translates to:
  /// **'Your room is full'**
  String get bag_regen_room_full;

  /// Generate refused: enough unused codes
  ///
  /// In en, this message translates to:
  /// **'You already have enough unused codes. Share them first!'**
  String get bag_regen_enough_unused;

  /// Generate refused: daily limit
  ///
  /// In en, this message translates to:
  /// **'No generations left today'**
  String get bag_regen_daily_limit;

  /// Generate refused: lifetime limit
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the most codes you can generate'**
  String get bag_regen_lifetime_limit;

  /// Share page app bar title
  ///
  /// In en, this message translates to:
  /// **'Share code'**
  String get share_title;

  /// Poster headline
  ///
  /// In en, this message translates to:
  /// **'Come visit my room!'**
  String get share_headline;

  /// Room size on the poster
  ///
  /// In en, this message translates to:
  /// **'Room {count} / {capacity}'**
  String share_room_count(int count, int capacity);

  /// Button that saves the poster to the gallery
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get share_save;

  /// Button that opens the system share sheet
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share_system;

  /// Text sent with the shared poster; code is XXXX-XXXX
  ///
  /// In en, this message translates to:
  /// **'Come visit my room! Code {code} {link}'**
  String share_text(String code, String link);

  /// SnackBar after saving the poster
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery'**
  String get share_saved;

  /// SnackBar when gallery permission is denied
  ///
  /// In en, this message translates to:
  /// **'Allow photo access to save the poster'**
  String get share_denied;

  /// Share page when the code is unknown or not unused
  ///
  /// In en, this message translates to:
  /// **'This code can no longer be shared'**
  String get share_unavailable;

  /// SnackBar when capturing, saving or sharing the poster fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the poster. Please try again.'**
  String get share_failed;

  /// App bar title of the room manage page.
  ///
  /// In en, this message translates to:
  /// **'Manage room'**
  String get manage_title;

  /// Room menu item (own room) that opens the manage page.
  ///
  /// In en, this message translates to:
  /// **'Manage room'**
  String get manage_open;

  /// Badge next to the owner in the manage page member list.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get manage_owner;

  /// Action to remove a member from the user's own room.
  ///
  /// In en, this message translates to:
  /// **'Remove from room'**
  String get manage_remove;

  /// Title of the confirm dialog before removing a member.
  ///
  /// In en, this message translates to:
  /// **'Remove from room?'**
  String get manage_remove_confirm_title;

  /// Body of the confirm dialog before removing a member; says they cannot join again.
  ///
  /// In en, this message translates to:
  /// **'{name} will leave your room and won\'t be able to join again.'**
  String manage_remove_confirm_body(String name);

  /// Button that dissolves the user's own room.
  ///
  /// In en, this message translates to:
  /// **'Dissolve room'**
  String get manage_dissolve;

  /// Title of the confirm dialog before dissolving the room.
  ///
  /// In en, this message translates to:
  /// **'Dissolve your room?'**
  String get manage_dissolve_confirm_title;

  /// Body of the dissolve confirm: everyone leaves, unused codes stop working, the room stays.
  ///
  /// In en, this message translates to:
  /// **'Everyone will leave and unused invite codes will stop working. Your room stays, so you can invite new friends.'**
  String get manage_dissolve_confirm_body;

  /// Room menu item (friend's room) that leaves it.
  ///
  /// In en, this message translates to:
  /// **'Leave room'**
  String get room_leave;

  /// Title of the confirm dialog before leaving a room.
  ///
  /// In en, this message translates to:
  /// **'Leave this room?'**
  String get room_leave_confirm_title;

  /// Body of the confirm dialog before leaving a room.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need a new invite code to join this room again.'**
  String get room_leave_confirm_body;

  /// Cancel button of confirm dialogs.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// Name shown for a room member with no nickname and no known pet.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get room_member_unknown;
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
