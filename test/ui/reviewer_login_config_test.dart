import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/config/shop_reviewer_login.dart';

void main() {
  test('Reviewer sign-in is opt-in and disabled by default', () {
    // Run ordinary test commands without any reviewer defines.
    expect(ShopReviewerLogin.enabled, isFalse);
    expect(ShopReviewerLogin.availableFor(isAdmin: true), isFalse);
    expect(ShopReviewerLogin.availableFor(isAdmin: false), isFalse);
  });
}
