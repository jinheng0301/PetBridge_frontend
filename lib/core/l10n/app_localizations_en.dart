// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PetBridge';

  @override
  String get err_UNKNOWN => 'Something went wrong. Please try again.';

  @override
  String get err_NETWORK =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get err_NOT_READY =>
      'The service is temporarily unavailable. Please try again in a moment.';

  @override
  String get err_VALIDATION_FAILED =>
      'Some of the information isn\'t valid. Please check and try again.';

  @override
  String get err_PROVIDER_NOT_CONFIGURED =>
      'This sign-in method isn\'t available right now.';

  @override
  String get err_ACCOUNT_DISABLED => 'This account has been disabled.';

  @override
  String get err_RATE_LIMITED =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get pet_lone_leopard_name => 'Lone Leopard';

  @override
  String get pet_lone_leopard_intro =>
      'Quiet and far-sighted. Lone Leopard makes a plan, then sees it through on its own terms.';

  @override
  String get pet_leader_lion_name => 'Leader Lion';

  @override
  String get pet_leader_lion_intro =>
      'Bold and decisive. Leader Lion sets the direction and gets everyone moving.';

  @override
  String get pet_thinker_owl_name => 'Thinker Owl';

  @override
  String get pet_thinker_owl_intro =>
      'Curious and logical. Thinker Owl loves asking why and turning ideas over.';

  @override
  String get pet_clever_fox_name => 'Clever Fox';

  @override
  String get pet_clever_fox_intro =>
      'Quick-witted and playful. Clever Fox always has a new idea or a fun debate ready.';

  @override
  String get pet_guardian_deer_name => 'Guardian Deer';

  @override
  String get pet_guardian_deer_intro =>
      'Gentle and insightful. Guardian Deer quietly understands what others feel.';

  @override
  String get pet_guide_dolphin_name => 'Guide Dolphin';

  @override
  String get pet_guide_dolphin_intro =>
      'Warm and encouraging. Guide Dolphin brings people together and lifts them up.';

  @override
  String get pet_healing_rabbit_name => 'Healing Rabbit';

  @override
  String get pet_healing_rabbit_intro =>
      'Kind and dreamy. Healing Rabbit listens closely and makes friends feel safe.';

  @override
  String get pet_happy_shiba_name => 'Happy Shiba';

  @override
  String get pet_happy_shiba_intro =>
      'Cheerful and full of ideas. Happy Shiba turns any day into an adventure.';

  @override
  String get pet_steady_beaver_name => 'Steady Beaver';

  @override
  String get pet_steady_beaver_intro =>
      'Reliable and hardworking. Steady Beaver builds things carefully, one step at a time.';

  @override
  String get pet_order_sheepdog_name => 'Order Sheepdog';

  @override
  String get pet_order_sheepdog_intro =>
      'Organized and dependable. Order Sheepdog keeps everyone on track.';

  @override
  String get pet_guardian_penguin_name => 'Guardian Penguin';

  @override
  String get pet_guardian_penguin_intro =>
      'Loyal and caring. Guardian Penguin remembers the little things that matter.';

  @override
  String get pet_warm_otter_name => 'Warm Otter';

  @override
  String get pet_warm_otter_intro =>
      'Friendly and attentive. Warm Otter makes sure no one feels left out.';

  @override
  String get pet_calm_blackcat_name => 'Calm Black Cat';

  @override
  String get pet_calm_blackcat_intro =>
      'Cool-headed and handy. Calm Black Cat stays steady and fixes what\'s broken.';

  @override
  String get pet_daring_falcon_name => 'Daring Falcon';

  @override
  String get pet_daring_falcon_intro =>
      'Energetic and fearless. Daring Falcon jumps in first and figures it out on the way.';

  @override
  String get pet_easygoing_alpaca_name => 'Easygoing Alpaca';

  @override
  String get pet_easygoing_alpaca_intro =>
      'Relaxed and artistic. Easygoing Alpaca enjoys the moment and notices beauty everywhere.';

  @override
  String get pet_party_parrot_name => 'Party Parrot';

  @override
  String get pet_party_parrot_intro =>
      'Lively and fun. Party Parrot brings the energy wherever it goes.';

  @override
  String get quiz_ei_prompt =>
      'After a busy week, on the weekend you\'d rather…';

  @override
  String get quiz_ei_a => 'Go out with friends and have fun';

  @override
  String get quiz_ei_b => 'Stay in and recharge on your own';

  @override
  String get quiz_sn_prompt =>
      'A friend tells you about a new movie. You want to know…';

  @override
  String get quiz_sn_a => 'What happens and who\'s in it';

  @override
  String get quiz_sn_b => 'What it\'s trying to say';

  @override
  String get quiz_tf_prompt =>
      'A friend made a not-so-great decision and asks you about it. You…';

  @override
  String get quiz_tf_a => 'Point out what went wrong';

  @override
  String get quiz_tf_b => 'Look after their feelings first';

  @override
  String get quiz_jp_prompt => 'When you travel, you usually…';

  @override
  String get quiz_jp_a => 'Plan the itinerary ahead';

  @override
  String get quiz_jp_b => 'Decide when you get there';

  @override
  String get err_APPLE_LOGIN_UNAVAILABLE =>
      'Sign in with Apple isn\'t available yet.';

  @override
  String get err_GOOGLE_SIGN_IN_FAILED =>
      'Google sign-in didn\'t work. Please try again.';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_retry => 'Try again';

  @override
  String get common_logout => 'Log out';

  @override
  String get login_google => 'Continue with Google';

  @override
  String get login_apple => 'Continue with Apple';

  @override
  String get login_apple_coming_soon => 'Sign in with Apple is coming soon.';

  @override
  String get login_dev_title => 'Developer login (dev only)';

  @override
  String get login_dev_email_label => 'Email';

  @override
  String get login_dev_submit => 'Log in';

  @override
  String onb_progress(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onb_lang_title => 'What\'s your language?';

  @override
  String get onb_lang_hint =>
      'The app will use it, and your friends\' messages will be translated into it.';

  @override
  String get onb_mbti_title => 'What\'s your MBTI type?';

  @override
  String get onb_mbti_not_sure => 'I\'m not sure — take a quick quiz';

  @override
  String onb_quiz_progress(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String get onb_quiz_result_title => 'Your type';

  @override
  String get onb_quiz_result_hint =>
      'Doesn\'t feel right? Tap a letter to switch it.';

  @override
  String get onb_quiz_result_confirm => 'Use this type';

  @override
  String get onb_reveal_title => 'Meet your pet';

  @override
  String get onb_profile_title => 'About you';

  @override
  String get onb_nickname_label => 'Nickname';

  @override
  String get onb_nickname_hint => '1–20 characters';

  @override
  String get onb_nickname_err_empty => 'Please enter a nickname.';

  @override
  String get onb_nickname_err_too_long =>
      'Nickname can be at most 20 characters.';

  @override
  String get onb_nickname_err_invalid =>
      'Nickname contains characters that are not allowed.';

  @override
  String get onb_nickname_err_server =>
      'This nickname can\'t be used. Please try another one.';

  @override
  String get onb_field_invalid => 'Please check this.';

  @override
  String get onb_age_label => 'Age';

  @override
  String get onb_age_under13 => 'Under 13';

  @override
  String get onb_age_teen => '13–17';

  @override
  String get onb_age_adult => '18 or older';

  @override
  String get onb_submit => 'Finish';

  @override
  String get onb_too_young_title => 'Sorry, you can\'t use PetBridge yet';

  @override
  String get onb_too_young_body =>
      'PetBridge is for people aged 13 and over. We hope to see you when you\'re older!';

  @override
  String get home_tab_room => 'Room';

  @override
  String get home_tab_chat => 'Chat';

  @override
  String get home_tab_bag => 'Backpack';

  @override
  String get home_tab_me => 'Me';

  @override
  String get home_coming_soon => 'Coming soon';

  @override
  String get me_nickname => 'Nickname';

  @override
  String get me_mbti => 'MBTI';

  @override
  String get me_pet => 'Pet';

  @override
  String get err_CODE_INVALID => 'This code is invalid or no longer works.';

  @override
  String get err_ROOM_FULL => 'This room is already full.';

  @override
  String get err_ALREADY_MEMBER => 'You\'re already in this room.';

  @override
  String get err_AGE_RESTRICTED => 'Minors and adults can\'t share a room.';

  @override
  String get err_ROOM_LIMIT => 'You\'re already in 2 rooms. Leave one first.';

  @override
  String get err_CODE_COOLDOWN => 'Too many attempts. Please try again later.';

  @override
  String get err_ONBOARDING_REQUIRED => 'Please finish signing up first.';

  @override
  String get err_CODE_ISSUE_LIMIT => 'Can\'t create a code right now.';

  @override
  String get err_NOT_ROOM_OWNER => 'You\'re not the owner of this room.';

  @override
  String get err_OWNER_CANNOT_LEAVE =>
      'The owner can\'t leave their own room. Dissolve it from the manage page instead.';

  @override
  String get err_ROOM_NOT_FOUND => 'This room no longer exists.';

  @override
  String get room_title_mine => 'My room';

  @override
  String room_title_of(String name) {
    return '$name\'s room';
  }

  @override
  String get room_title_friend => 'A friend\'s room';

  @override
  String room_count(int count, int capacity) {
    return '$count/$capacity';
  }

  @override
  String get room_invite => 'Invite friends';

  @override
  String get room_join_button => 'Enter a code';

  @override
  String get room_solo_card =>
      'You\'re the only one here. Invite friends, or use a code to visit a friend\'s room.';

  @override
  String get room_seat_invite => '+ Invite';

  @override
  String get room_reconnecting => 'Reconnecting…';

  @override
  String get join_title => 'Enter invite code';

  @override
  String get join_hint => 'Enter the 8-character code a friend shared with you';

  @override
  String get join_paste => 'Paste';

  @override
  String get join_submit => 'Join room';

  @override
  String join_retry_in(String time) {
    return 'Too many tries. Try again in $time';
  }

  @override
  String get join_go_room => 'Go to room';

  @override
  String get join_success_title => 'Welcome in!';

  @override
  String join_success_body(String room) {
    return 'You joined $room';
  }

  @override
  String get join_reward_title => 'A gift for you';

  @override
  String get join_reward_body =>
      'Share it with friends so they can move into your room';

  @override
  String get join_share => 'Share';

  @override
  String get bag_title => 'Backpack';

  @override
  String get bag_join => 'Enter code';

  @override
  String get bag_status_unused => 'Unused';

  @override
  String get bag_status_used => 'Used';

  @override
  String get bag_status_expired => 'Expired';

  @override
  String get bag_status_void => 'Void';

  @override
  String bag_room_count(int count, int capacity) {
    return 'Room $count/$capacity';
  }

  @override
  String bag_days_left(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String bag_hours_left(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours left',
      one: '1 hour left',
    );
    return '$_temp0';
  }

  @override
  String get bag_expiring => 'Expiring soon';

  @override
  String get bag_share => 'Share';

  @override
  String get bag_regen => 'Generate code';

  @override
  String get bag_regen_full => 'Your room is full. Free up a seat first.';

  @override
  String bag_regen_remaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You can generate $count more today',
      one: 'You can generate 1 more today',
    );
    return '$_temp0';
  }

  @override
  String get bag_regen_none_left => 'No generations left today';

  @override
  String get bag_regen_done => 'New code generated';

  @override
  String get bag_empty => 'No codes yet';

  @override
  String get bag_regen_room_full => 'Your room is full';

  @override
  String get bag_regen_enough_unused =>
      'You already have enough unused codes. Share them first!';

  @override
  String get bag_regen_daily_limit => 'No generations left today';

  @override
  String get bag_regen_lifetime_limit =>
      'You\'ve reached the most codes you can generate';

  @override
  String get share_title => 'Share code';

  @override
  String get share_headline => 'Come visit my room!';

  @override
  String share_room_count(int count, int capacity) {
    return 'Room $count / $capacity';
  }

  @override
  String get share_save => 'Save to gallery';

  @override
  String get share_system => 'Share';

  @override
  String share_text(String code, String link) {
    return 'Come visit my room! Code $code $link';
  }

  @override
  String get share_saved => 'Saved to gallery';

  @override
  String get share_denied => 'Allow photo access to save the poster';

  @override
  String get share_unavailable => 'This code can no longer be shared';

  @override
  String get share_failed => 'Couldn\'t create the poster. Please try again.';

  @override
  String get manage_title => 'Manage room';

  @override
  String get manage_open => 'Manage room';

  @override
  String get manage_owner => 'Owner';

  @override
  String get manage_remove => 'Remove from room';

  @override
  String get manage_remove_confirm_title => 'Remove from room?';

  @override
  String manage_remove_confirm_body(String name) {
    return '$name will leave your room and won\'t be able to join again.';
  }

  @override
  String get manage_dissolve => 'Dissolve room';

  @override
  String get manage_dissolve_confirm_title => 'Dissolve your room?';

  @override
  String get manage_dissolve_confirm_body =>
      'Everyone will leave and unused invite codes will stop working. Your room stays, so you can invite new friends.';

  @override
  String get room_leave => 'Leave room';

  @override
  String get room_leave_confirm_title => 'Leave this room?';

  @override
  String get room_leave_confirm_body =>
      'You\'ll need a new invite code to join this room again.';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get room_member_unknown => 'Friend';

  @override
  String get room_left_notice => 'You\'ve left this room';
}
