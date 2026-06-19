import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'fake_image_picker_config.dart';
import 'fake_image_picker_platform.dart';

/// A drop-in test replacement for the [ImagePicker] facade.
///
/// After calling [FakeImagePicker.register], both [ImagePicker] and this class
/// will use the same fake platform instance, so tests can be written with
/// either API.
class FakeImagePicker {
  /// Creates a facade that delegates to [platform].
  ///
  /// If [platform] is omitted, the global [ImagePickerPlatform.instance] is
  /// used. This makes the class work immediately after [register] has been
  /// called.
  FakeImagePicker({ImagePickerPlatform? platform})
    : _platform = platform ?? ImagePickerPlatform.instance;

  final ImagePickerPlatform _platform;

  static FakeImagePickerPlatform? _registeredPlatform;
  static ImagePickerPlatform? _originalPlatform;

  /// Registers a fake platform as the global [ImagePickerPlatform.instance].
  ///
  /// Call [unregister] in `tearDown` to restore the original platform.
  static FakeImagePickerPlatform register({
    FakeImagePickerConfiguration? configuration,
  }) {
    if (_registeredPlatform != null) {
      unregister();
    }

    _originalPlatform = ImagePickerPlatform.instance;
    _registeredPlatform = FakeImagePickerPlatform(
      configuration: configuration ?? FakeImagePickerConfiguration(),
    );
    ImagePickerPlatform.instance = _registeredPlatform!;
    return _registeredPlatform!;
  }

  /// Restores the original [ImagePickerPlatform.instance].
  ///
  /// Safe to call even if [register] was never called.
  static void unregister() {
    final original = _originalPlatform;
    if (original != null) {
      ImagePickerPlatform.instance = original;
      _originalPlatform = null;
    }
    _registeredPlatform = null;
  }

  /// Returns the platform registered by [register], if any.
  static FakeImagePickerPlatform? get registeredPlatform => _registeredPlatform;

  /// Returns an [XFile] object wrapping the fake image that was picked.
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) {
    return _platform.getImageFromSource(
      source: source,
      options: ImagePickerOptions.createAndValidate(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
        requestFullMetadata: requestFullMetadata,
      ),
    );
  }

  /// Returns a [List<XFile>] object wrapping the fake images that were picked.
  Future<List<XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) {
    return _platform.getMultiImageWithOptions(
      options: MultiImagePickerOptions.createAndValidate(
        imageOptions: ImageOptions.createAndValidate(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
          requestFullMetadata: requestFullMetadata,
        ),
        limit: limit,
      ),
    );
  }

  /// Returns an [XFile] of the fake image or video that was picked.
  Future<XFile?> pickMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = true,
  }) async {
    final listMedia = await _platform.getMedia(
      options: MediaOptions.createAndValidate(
        imageOptions: ImageOptions.createAndValidate(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          imageQuality: imageQuality,
          requestFullMetadata: requestFullMetadata,
        ),
        allowMultiple: false,
      ),
    );
    return listMedia.isNotEmpty ? listMedia.first : null;
  }

  /// Returns a [List<XFile>] with the fake images and/or videos that were picked.
  Future<List<XFile>> pickMultipleMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) {
    return _platform.getMedia(
      options: MediaOptions.createAndValidate(
        allowMultiple: true,
        imageOptions: ImageOptions.createAndValidate(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          imageQuality: imageQuality,
          requestFullMetadata: requestFullMetadata,
        ),
        limit: limit,
      ),
    );
  }

  /// Returns an [XFile] object wrapping the fake video that was picked.
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) {
    return _platform.getVideo(
      source: source,
      preferredCameraDevice: preferredCameraDevice,
      maxDuration: maxDuration,
    );
  }

  /// Returns a [List<XFile>] of the fake videos that were picked.
  Future<List<XFile>> pickMultiVideo({Duration? maxDuration, int? limit}) {
    return _platform.getMultiVideoWithOptions(
      options: MultiVideoPickerOptions(maxDuration: maxDuration, limit: limit),
    );
  }

  /// Retrieve the lost [XFile] when a pick failed because the MainActivity
  /// was destroyed (Android only in the real plugin).
  Future<LostDataResponse> retrieveLostData() => _platform.getLostData();

  /// Returns true if the simulated platform supports [source].
  bool supportsImageSource(ImageSource source) =>
      _platform.supportsImageSource(source);
}
