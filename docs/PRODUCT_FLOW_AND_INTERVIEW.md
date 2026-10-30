# Product feature: data flow + interview preparation

## 1. What happens when an admin creates a product?

1. The admin signs in through Firebase Authentication.
2. `ShopSessionController` listens to their Auth state and reads `users/{uid}`.
3. `ShopAuthGate` displays `AdminProductsScreen` only when the profile role is `admin`.
4. The admin fills `ProductFormScreen`. `Form` validators check input before sending.
5. `ProductFormController` reads each `TextEditingController`, sets `isSaving` to true, then calls `ProductService.saveProduct`.
6. `ProductService` calls `FirebaseFirestore.instance.collection('products').add(...)`.
7. Firestore **security rules** check the Firebase identity, stored admin role, and fields before accepting the write.
8. The Firestore `snapshots()` stream emits updated data; the GetX controller updates its RxList, and `Obx()` rebuilds the product UI.

## 2. Why these files?

- `ShopProduct` model: a simple Dart representation of a Firestore document.
- `ProductService`: all Firestore queries and writes in one place, not scattered across widgets.
- `CustomerCatalogController` / `AdminProductsController`: listen to product streams, expose reactive products and loading/error state.
- `ProductFormController`: holds form values, validation state and save progress.
- `ShopProductCard`: a single reusable product presentation for catalog grids.
- Screens: visual layout, user events and navigation; they don't write Firestore directly.
- `ShopAuthGate`: selects the correct screen based on user role. **It is not a security boundary**; Firestore Rules are.

## 3. Firebase concepts

**Collection and document:** `products` is a collection. Every product is a document with an automatically generated ID. Models keep the document ID so edits and deletes know which document to target.

**`snapshots()` vs `get()`:** `.get()` returns data once. `.snapshots()` returns a Stream and can deliver later changes. We use snapshots so admin edits appear live in the catalog.

**`FieldValue.serverTimestamp()`:** Requests the backend to write a server timestamp, rather than trusting the device's clock. Rules check that this timestamp equals `request.time`.

**Why separate Firebase Auth and Firestore?** Auth proves the user identity and issues an authenticated token. Firestore stores business data and profiles. Rules use the Auth UID to check a user's profile role before allowing admin writes.

**Why a customer query filters `isActive`?** Rules allow customers to read only published products. Firestore Rules are not filters: querying the full collection as a customer would be denied, so the customer query includes `where('isActive', isEqualTo: true)`.

**Why an admin document is not created from the customer app:** If customers could set their own `role = admin`, they could gain write access. The customer create rules require `role = customer`, and role changes are blocked.

**Firebase Storage:** Firestore stores structured metadata, not image file bytes. A later feature can upload image bytes to Cloud Storage and save the resulting download URL in the product document. Storage needs Blaze for new/current projects and its own security rules.

## 4. GetX concepts

- `.obs`: turns a value/list into reactive GetX state.
- `Obx`: only rebuilds UI that reads observed values.
- `GetxController`: groups screen logic and state.
- `ever(session.profile, ...)`: listens for changes in the signed-in user's role/profile. When logging out, the product stream is cancelled. On login to a matching role, it starts.
- `Get.put`: registers shared dependencies and controllers.
- `Get.find`: locates an already-registered dependency.
- `BindingsBuilder`: provides the short-lived product editor controller when opening the form page.
- `onClose`: disposes the TextEditingControllers and stream subscriptions to prevent leaks.

## 5. Interview Q&A

**Q: Why did you choose GetX?**  
A: It reduces UI boilerplate and provides reactive state, navigation and dependency injection. I separated Firebase calls into services so my controllers remain understandable.

**Q: Why use Firestore `snapshots()`?**  
A: It delivers real-time updates to all signed-in clients. When the admin edits a product, the customer catalog updates without manual refreshing.

**Q: How does the customer app avoid seeing hidden products?**  
A: The query requests `isActive == true`, and Firestore Rules also deny reads on hidden product documents for non-admin users.

**Q: Is hiding the admin button enough to secure the backend?**  
A: No. Clients can be modified. Firestore Security Rules check the authenticated user and administrator role on the server.

**Q: How are the prices represented?**  
A: Integer rupees for this machine-test MVP, with validation. To support paise later, I would use integer minor units instead of floating point.

**Q: What if the network disconnects?**  
A: Snapshot listeners may use cached data depending on platform settings; writes can fail or be delayed. I show loading/error states and would add clearer offline handling for production.

**Q: Why keep some code in a service?**  
A: To avoid mixing backend logic and widgets, simplify testing, and use the same database calls from customer and admin features.

**Q: Why not use Cloud Storage now?**  
A: The product catalog and CRUD are the next testable milestone, and the current Spark plan does not include Cloud Storage access. A later upload feature will use Storage with admin-only rules and retain product URLs in Firestore.

**Q: What is a composite index?**  
A: Firestore may require it for queries combining certain filters and sort orders. This product feature uses a simple equality filter and sorts locally to avoid an unnecessary composite index.
