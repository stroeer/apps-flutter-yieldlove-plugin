import 'package:sourcepoint_cmp/action_type.dart';
import 'package:sourcepoint_cmp/gdpr_user_consent.dart';

abstract class ConsentListener {

  void onConsentGiven(GDPRUserConsent consent) {}

  void onError(String? errorMessage) {}

  void onConsentUIReady() {}

  void onConsentUIFinished() {}

  void onAction(ActionType actionType) {}

}