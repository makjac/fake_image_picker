## 1.0.2

- Aligns `FakeImagePicker.pickMultiImage` and `FakeImagePicker.pickMultipleMedia` with `image_picker` 1.2.3:
  - `limit: 1` now delegates to the single-item picker instead of throwing an `ArgumentError`.
  - Values of `limit` below `1` now throw `ArgumentError` from the facade.
- Updates minimum supported Flutter version to `3.38.0`.

## 1.0.1

- Updated package description to meet pub.dev guidelines.

## 1.0.0

- Initial release.
- Fake implementation of `ImagePickerPlatform` covering every public method of `image_picker` 1.2.2.
- Deterministic, random, custom, and empty data sources.
- Platform presets for Android, iOS, macOS, Windows, Linux, Web, and universal behavior.
- Behavior injection for delays, cancellation, errors, and "plugin already in use".
- Global `FakeImagePicker.register()` / `unregister()` helpers plus DI-friendly `FakeImagePickerPlatform`.
- Comprehensive test suite and example project.
