# fake_image_picker

[![pub package](https://img.shields.io/pub/v/fake_image_picker.svg)](https://pub.dev/packages/fake_image_picker)
[![build](https://img.shields.io/github/actions/workflow/status/makjac/fake_image_picker/ci.yml?branch=main)](https://github.com/makjac/fake_image_picker/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/makjac/fake_image_picker/branch/main/graph/badge.svg)](https://codecov.io/gh/makjac/fake_image_picker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A ready-to-use fake for the Flutter [`image_picker`](https://pub.dev/packages/image_picker) plugin.
Add it to your `dev_dependencies`, call one line of setup, and control exactly what your unit tests receive from the image picker — no manual mocks, no platform channels, no filesystem side effects.

**Target `image_picker` version:** `1.2.3`  
**Supported platforms in tests:** Android, iOS, macOS, Windows, Linux, Web.

---

## Why?

Testing code that uses `image_picker` normally requires mocking `ImagePickerPlatform`, dealing with method channels, or creating temporary files. `fake_image_picker` gives you:

- **Zero-config registration** — `FakeImagePicker.register()` replaces the platform instance globally.
- **Dependency-injection friendly** — construct `FakeImagePickerPlatform` and inject it directly.
- **Custom, random, or deterministic data** — choose the data source that fits your test.
- **Platform simulation** — test Android lost-data flows, desktop camera delegation, web limits, and more.
- **Behavior injection** — simulate delays, cancellations, permission errors, and "plugin already in use".

---

## Copy-paste test snippet

```dart
import 'package:fake_image_picker/fake_image_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  setUp(() => FakeImagePicker.register());
  tearDown(() => FakeImagePicker.unregister());

  test('user picks a gallery image', () async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    expect(image, isNotNull);
    expect(image!.path, startsWith('fake:///image_'));
  });
}
```

---

## Getting started

Add the package to your `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  fake_image_picker: ^1.0.0
```

Then run:

```bash
flutter pub get
```

In your test file, register the fake before tests and unregister after:

```dart
setUp(() => FakeImagePicker.register());
tearDown(() => FakeImagePicker.unregister());
```

You can now use the real `ImagePicker` API in your tests; it will talk to the fake platform behind the scenes.

---

## Usage

### Global registration

```dart
FakeImagePicker.register();

final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.gallery);

FakeImagePicker.unregister();
```

### Dependency injection

```dart
final platform = FakeImagePickerPlatform(
  configuration: FakeImagePickerConfiguration(
    dataSource: CustomFakeDataSource()..queueImage(myXFile),
    platform: FakePlatform.android.constraints,
  ),
);

final repository = MyRepository(imagePickerPlatform: platform);
```

### Custom responses

```dart
final myFile = XFile.fromData(
  bytes,
  path: 'fake:///profile.jpg',
  name: 'profile.jpg',
  mimeType: 'image/jpeg',
);

FakeImagePicker.register(
  configuration: FakeImagePickerConfiguration(
    dataSource: CustomFakeDataSource()..queueImage(myFile),
  ),
);
```

### Simulate cancellation

```dart
FakeImagePicker.register(
  configuration: FakeImagePickerConfiguration(
    dataSource: EmptyFakeDataSource(),
  ),
);

final image = await ImagePicker().pickImage(source: ImageSource.gallery);
expect(image, isNull);
```

### Simulate errors

```dart
FakeImagePicker.register(
  configuration: FakeImagePickerConfiguration(
    behavior: FakeImagePickerBehavior(
      platformException: PlatformException(
        code: 'photo_access_denied',
        message: 'User did not allow photo access.',
      ),
    ),
  ),
);

await expectLater(
  () => ImagePicker().pickImage(source: ImageSource.gallery),
  throwsA(isA<PlatformException>()),
);
```

---

## Data sources

| Data source | Description |
| ------------- | ------------- |
| `PredefinedFakeDataSource` | Deterministic fake files (`fake:///image_1.jpg`, `fake:///video_1.mp4`). Default. |
| `RandomFakeDataSource` | Random file names, sizes, and bytes. Optionally seeded for reproducibility. |
| `CustomFakeDataSource` | Queue exact `XFile?`, `List<XFile>`, `LostDataResponse`, or error responses. |
| `EmptyFakeDataSource` | Always returns `null` or empty lists to simulate cancellation. |

---

## Platform simulation

Use `FakePlatform` presets to simulate the behavior of different platforms:

| Platform | `ImageSource.gallery` | `ImageSource.camera` | Lost data | Notes |
| ---------- | ---------------------- | ---------------------- | ----------- | ------- |
| `FakePlatform.android` | ✅ | ✅ | ✅ | Full mobile behavior. |
| `FakePlatform.ios` | ✅ | ✅ | ❌ | Matches iOS limitations. |
| `FakePlatform.macos` | ✅ | ❌* | ❌ | Camera requires a `cameraDelegate`. |
| `FakePlatform.windows` | ✅ | ❌* | ❌ | Camera requires a `cameraDelegate`. |
| `FakePlatform.linux` | ✅ | ❌* | ❌ | Camera requires a `cameraDelegate`. |
| `FakePlatform.web` | ✅ | ✅ | ❌ | `limit` is ignored, like the web plugin. |
| `FakePlatform.universal` | ✅ | ✅ | ✅ | Everything enabled; great for quick tests. |

\* Camera is supported only if a `cameraDelegate` is supplied, matching the real desktop implementations.

```dart
FakeImagePicker.register(
  configuration: FakeImagePickerConfiguration(
    platform: FakePlatform.android.constraints,
  ),
);

final response = await ImagePicker().retrieveLostData();
expect(response.isEmpty, isFalse);
```

---

## Behavior injection

`FakeImagePickerBehavior` lets you inject runtime behavior without touching the data source:

```dart
FakeImagePicker.register(
  configuration: FakeImagePickerConfiguration(
    behavior: const FakeImagePickerBehavior(
      responseDelay: Duration(seconds: 1),
      autoCancel: true,
      maxSequentialPicks: 2,
    ),
  ),
);
```

Available options:

- `responseDelay` — delay every response.
- `autoCancel` — always return `null` or empty lists.
- `exception` / `platformException` — throw on the next call.
- `maxSequentialPicks` — throw `PlatformException(code: 'already_active')` after N picks.

---

## API overview

### `FakeImagePicker`

A facade that mirrors the public `ImagePicker` API.

- `FakeImagePicker.register(...)` / `FakeImagePicker.unregister()`
- `pickImage(...)`, `pickMultiImage(...)`, `pickMedia(...)`, `pickMultipleMedia(...)`
- `pickVideo(...)`, `pickMultiVideo(...)`
- `retrieveLostData()`
- `supportsImageSource(...)`

### `FakeImagePickerPlatform`

A full implementation of `ImagePickerPlatform`. Use it directly for DI.

### `FakeImagePickerConfiguration`

Bundles the data source, platform constraints, and behavior.

### `FakePlatform` / `FakePlatformConstraints`

Simulate Android, iOS, macOS, Windows, Linux, Web, or a universal platform.
