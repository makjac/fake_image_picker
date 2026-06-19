## 1.0.0

- Initial release.
- Fake implementation of `ImagePickerPlatform` covering every public method of `image_picker` 1.2.2.
- Deterministic, random, custom, and empty data sources.
- Platform presets for Android, iOS, macOS, Windows, Linux, Web, and universal behavior.
- Behavior injection for delays, cancellation, errors, and "plugin already in use".
- Global `FakeImagePicker.register()` / `unregister()` helpers plus DI-friendly `FakeImagePickerPlatform`.
- Comprehensive test suite and example project.
