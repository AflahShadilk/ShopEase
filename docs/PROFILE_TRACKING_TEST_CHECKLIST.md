# Live test checklist

- [ ] Admin login opens product management and shows the Customers icon.
- [ ] Customer directory contains signed-up customer accounts (not admin profiles).
- [ ] Search finds a customer by name and email.
- [ ] Selecting a customer displays only that customer's orders.
- [ ] Admin sees zero-history state for customer with no orders.
- [ ] Existing admin Orders screen can update order status.
- [ ] Customer sees the new status in My Orders timeline after the Firestore stream updates.
- [ ] Cancelled order shows cancelled state, not false delivery progress.
- [ ] Customer cannot list other customer profiles or view their orders (Firebase security rules).
- [ ] Responsive manual checks at 320, 375, 768, 1280 CSS/logical pixels; test text scale 1.3.
- [ ] Sign-out cleans up subscription data and admin/customer routes don't disclose stale data.

The summary labeled **Non-cancelled order value** is the sum of all recorded non-cancelled orders, not verified revenue or payments.
