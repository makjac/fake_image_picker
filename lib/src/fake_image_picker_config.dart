import 'data_source/fake_data_source.dart';
import 'data_source/predefined_data_source.dart';
import 'fake_image_picker_behavior.dart';
import 'platform/fake_platform.dart';
import 'platform/fake_platform_constraints.dart';

/// Immutable configuration for [FakeImagePickerPlatform].
class FakeImagePickerConfiguration {
  /// Creates a configuration.
  ///
  /// Defaults produce a universal platform with deterministic fake data.
  FakeImagePickerConfiguration({
    FakeImagePickerDataSource? dataSource,
    FakePlatformConstraints? platform,
    FakeImagePickerBehavior? behavior,
  })  : dataSource = dataSource ?? PredefinedFakeDataSource(),
        platform = platform ?? FakePlatform.universal.constraints,
        behavior = behavior ?? const FakeImagePickerBehavior();

  /// The source of synthetic files.
  final FakeImagePickerDataSource dataSource;

  /// Simulated platform capabilities.
  final FakePlatformConstraints platform;

  /// Runtime behavior such as delays, cancellation, and errors.
  final FakeImagePickerBehavior behavior;

  /// Returns a copy with the supplied fields replaced.
  FakeImagePickerConfiguration copyWith({
    FakeImagePickerDataSource? dataSource,
    FakePlatformConstraints? platform,
    FakeImagePickerBehavior? behavior,
  }) {
    return FakeImagePickerConfiguration(
      dataSource: dataSource ?? this.dataSource,
      platform: platform ?? this.platform,
      behavior: behavior ?? this.behavior,
    );
  }
}
