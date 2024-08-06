import 'package:easy_ringtube/core/translates/localizations.dart';
import 'package:easy_ringtube/main.dart';

String appTranslate(String key, {Map<String, String>? arguments}) {
  final context = NavigationContextService.navigatorKey.currentContext;
  return AppLocalizations.of(context!)?.trans(context, key, arguments) ??
      "wrong key";
}
