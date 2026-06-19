import 'package:meta/meta.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Describes what a simulated platform is capable of.
///
/// Create one directly for full control, or use [FakePlatform] presets.
@immutable
class FakePlatformConstraints {
  /// Creates platform constraints.
  const FakePlatformConstraints({
    required this.supportedSources,
    this.supportsLostData = false,
    this.supportsCameraDelegate = false,
    this.supportsMultipleSelection = true,
    this.respectsLimit = true,
  });

  /// Which [ImageSource] values are natively supported.
  final Set<ImageSource> supportedSources;

  /// Whether [retrieveLostData] / [getLostData] is supported.
  final bool supportsLostData;

  /// Whether the platform can delegate camera handling to a
  /// [ImagePickerCameraDelegate].
  final bool supportsCameraDelegate;

  /// Whether multi-selection methods return more than one file.
  final bool supportsMultipleSelection;

  /// Whether the `limit` argument is enforced.
  final bool respectsLimit;

  /// Returns `true` if [source] is natively supported.
  bool supportsImageSource(ImageSource source) => supportedSources.contains(source);

  /// Returns a copy with the supplied fields replaced.
  FakePlatformConstraints copyWith({
    Set<ImageSource>? supportedSources,
    bool? supportsLostData,
    bool? supportsCameraDelegate,
    bool? supportsMultipleSelection,
    bool? respectsLimit,
  }) {
    return FakePlatformConstraints(
      supportedSources: supportedSources ?? this.supportedSources,
      supportsLostData: supportsLostData ?? this.supportsLostData,
      supportsCameraDelegate: supportsCameraDelegate ?? this.supportsCameraDelegate,
      supportsMultipleSelection: supportsMultipleSelection ?? this.supportsMultipleSelection,
      respectsLimit: respectsLimit ?? this.respectsLimit,
    );
  }
}
