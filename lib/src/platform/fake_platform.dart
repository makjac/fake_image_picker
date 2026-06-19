import 'fake_platform_constraints.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Known platforms that [FakeImagePickerPlatform] can simulate.
enum FakePlatform {
  android,
  ios,
  macos,
  windows,
  linux,
  web,
  universal;

  /// Supports everything; useful for quick, platform-agnostic tests.
  static FakePlatformConstraints universalConstraints() =>
      const FakePlatformConstraints(
        supportedSources: {ImageSource.gallery, ImageSource.camera},
        supportsLostData: true,
        supportsCameraDelegate: true,
        supportsMultipleSelection: true,
        respectsLimit: true,
      );

  /// Android: supports gallery, camera, multi-selection, and lost data.
  static FakePlatformConstraints androidConstraints() =>
      const FakePlatformConstraints(
        supportedSources: {ImageSource.gallery, ImageSource.camera},
        supportsLostData: true,
        supportsCameraDelegate: false,
        supportsMultipleSelection: true,
        respectsLimit: true,
      );

  /// iOS: supports gallery, camera, and multi-selection. No lost data.
  static FakePlatformConstraints iosConstraints() =>
      const FakePlatformConstraints(
        supportedSources: {ImageSource.gallery, ImageSource.camera},
        supportsLostData: false,
        supportsCameraDelegate: false,
        supportsMultipleSelection: true,
        respectsLimit: true,
      );

  /// macOS: by default no camera unless a delegate is supplied.
  static FakePlatformConstraints macosConstraints() =>
      const FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
        supportsLostData: false,
        supportsCameraDelegate: true,
        supportsMultipleSelection: true,
        respectsLimit: true,
      );

  /// Windows: by default no camera unless a delegate is supplied.
  static FakePlatformConstraints windowsConstraints() =>
      const FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
        supportsLostData: false,
        supportsCameraDelegate: true,
        supportsMultipleSelection: true,
        respectsLimit: true,
      );

  /// Linux: by default no camera unless a delegate is supplied.
  static FakePlatformConstraints linuxConstraints() =>
      const FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
        supportsLostData: false,
        supportsCameraDelegate: true,
        supportsMultipleSelection: true,
        respectsLimit: true,
      );

  /// Web: supports gallery and camera (through `capture` attribute). No lost
  /// data. Some options, such as `maxDuration`, are ignored.
  static FakePlatformConstraints webConstraints() =>
      const FakePlatformConstraints(
        supportedSources: {ImageSource.gallery, ImageSource.camera},
        supportsLostData: false,
        supportsCameraDelegate: false,
        supportsMultipleSelection: true,
        respectsLimit: false,
      );
}

/// Convenience extension to resolve a [FakePlatform] to its constraints.
extension FakePlatformConstraintsResolver on FakePlatform {
  FakePlatformConstraints get constraints {
    return switch (this) {
      FakePlatform.android => FakePlatform.androidConstraints(),
      FakePlatform.ios => FakePlatform.iosConstraints(),
      FakePlatform.macos => FakePlatform.macosConstraints(),
      FakePlatform.windows => FakePlatform.windowsConstraints(),
      FakePlatform.linux => FakePlatform.linuxConstraints(),
      FakePlatform.web => FakePlatform.webConstraints(),
      FakePlatform.universal => FakePlatform.universalConstraints(),
    };
  }
}
