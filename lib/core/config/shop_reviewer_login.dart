/// Optional credentials for a TEMPORARY REVIEW BUILD ONLY.
///
/// Do not embed a real administrator account in a publicly hosted web app:
/// --dart-define values are embedded in the compiled output and are readable.
/// These values are never checked into source control.
class ShopReviewerLogin {
  const ShopReviewerLogin._();

  static const bool enabled =
      bool.fromEnvironment('SHOP_REVIEW_MODE', defaultValue: false);

  static const String adminEmail =
      String.fromEnvironment('SHOP_REVIEW_ADMIN_EMAIL');
  static const String adminPassword =
      String.fromEnvironment('SHOP_REVIEW_ADMIN_PASSWORD');
  static const String customerEmail =
      String.fromEnvironment('SHOP_REVIEW_CUSTOMER_EMAIL');
  static const String customerPassword =
      String.fromEnvironment('SHOP_REVIEW_CUSTOMER_PASSWORD');

  static String emailFor({required bool isAdmin}) =>
      isAdmin ? adminEmail : customerEmail;

  static String passwordFor({required bool isAdmin}) =>
      isAdmin ? adminPassword : customerPassword;

  static bool availableFor({required bool isAdmin}) =>
      enabled &&
      emailFor(isAdmin: isAdmin).trim().isNotEmpty &&
      passwordFor(isAdmin: isAdmin).isNotEmpty;
}
