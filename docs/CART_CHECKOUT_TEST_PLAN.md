# ShopEase cart and checkout — manual QA

## Functional

- [ ] Customer sees cart badge and orders button in catalog.
- [ ] Product details offer Add to bag only for active items in stock.
- [ ] Cart add, increment, decrement, remove and totals work.
- [ ] Quantity never exceeds current stock.
- [ ] Customer catalog updates change cart price/stock; hidden products are removed.
- [ ] Cart is cleared on logout/account switch.
- [ ] Checkout validates name, 10-digit mobile number, complete address.
- [ ] Cash-on-delivery request creates `orders/{autoId}` in Firestore with status `pending`.
- [ ] Customer sees only their own orders.
- [ ] Admin can view order details and change order status.
- [ ] Customer cannot update order status or view another customer's order.
- [ ] Unauthenticated users cannot create orders.
- [ ] Admin confirms product price/availability independently before fulfilling.

## UI

- [ ] Customer catalog, bag, checkout, order history and admin orders at 320, 375, 768, 1280 widths.
- [ ] Repeat at enlarged text scale 1.3, landscape and with soft keyboard.
- [ ] Check every scroll container and button for clipping and overflow.
- [ ] Actual Android customer app and Chrome admin app tested separately.

## Security / production disclaimer

This demo deliberately stores *pending, untrusted* order requests. Firestore rules constrain authorization but cannot independently validate every item price, reserve stock, or prove order totals. Real checkout requires trusted server-side price calculation, stock reservation, idempotency and payment verification. Do not release production fulfillment or charge users based on these order documents alone.
