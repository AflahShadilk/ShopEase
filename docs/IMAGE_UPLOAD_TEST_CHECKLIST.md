# Product image upload — Live test checklist

- [ ] `flutter analyze` returns No issues found.
- [ ] `flutter test test/image_upload/` passes all tests, no RenderFlex overflow at 320 / 375 / 768 / 1280 px (100% & 130% text).
- [ ] Chrome admin: can select a JPEG and see preview; Clear selection restores existing image.
- [ ] Android admin: can select image from gallery (if admin build targeted for Android).
- [ ] JPG / PNG / WebP under 5 MB accepted.
- [ ] PDF, misleading extension and >= 5 MB rejected before upload.
- [ ] Image URL alternative still works when Storage isn't configured.
- [ ] Firestore `products/{id}.imageUrl` updates after successful upload.
- [ ] Customer catalog image appears on Chrome and Android.
- [ ] Storage Rules prevent a signed-in CUSTOMER from uploading.
- [ ] Storage Rules prevent uploading files other than images and >= 5 MB.
- [ ] Storage Rules restrict upload/delete to administrator under `product_images/{adminUid}`.
- [ ] Firebase console uses `storage.rules` in STORAGE section, and existing `firestore.rules` remains unchanged.
- [ ] Confirm Blaze plan and set budget alerts if using Storage.
- [ ] Verify replacement/deletion doesn't automatically remove old Storage objects; schedule cleanup later.
