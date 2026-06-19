import 'package:flutter/services.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'data_source/fake_data_source.dart';
import 'fake_image_picker_behavior.dart';
import 'fake_image_picker_config.dart';
import 'platform/fake_platform_constraints.dart';

/// A fully functional fake implementation of [ImagePickerPlatform].
///
/// Use it directly for dependency injection:
///
/// ```dart
/// final platform = FakeImagePickerPlatform(
///   configuration: FakeImagePickerConfiguration(
///     dataSource: CustomFakeDataSource()..queueImage(myXFile),
///     platform: FakePlatform.android.constraints,
///   ),
/// );
/// ```
///
/// Or register it globally with [FakeImagePicker.register].
class FakeImagePickerPlatform extends ImagePickerPlatform {
  /// Creates the fake platform with the given [configuration].
  FakeImagePickerPlatform({FakeImagePickerConfiguration? configuration})
      : configuration = configuration ?? FakeImagePickerConfiguration();

  /// Current configuration.
  FakeImagePickerConfiguration configuration;

  int _successfulPicks = 0;

  FakeImagePickerDataSource get _dataSource => configuration.dataSource;

  FakePlatformConstraints get _platform => configuration.platform;

  FakeImagePickerBehavior get _behavior => configuration.behavior;

  Future<T> _applyBehavior<T>(T fallback, Future<T> Function() action) async {
    final delay = _behavior.responseDelay;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }

    final platformException = _behavior.platformException;
    if (platformException != null) {
      throw platformException;
    }

    final exception = _behavior.exception;
    if (exception != null) {
      throw exception;
    }

    if (_behavior.autoCancel) {
      return fallback;
    }

    final maxPicks = _behavior.maxSequentialPicks;
    if (maxPicks != null && _successfulPicks >= maxPicks) {
      throw PlatformException(
        code: 'already_active',
        message: 'The image picker is already in use.',
      );
    }

    final result = await action();
    _successfulPicks++;
    return result;
  }

  void _ensureSourceSupported(ImageSource source) {
    if (!_platform.supportsImageSource(source)) {
      throw PlatformException(
        code: 'unsupported_source',
        message: 'ImageSource.$source is not supported on the simulated platform.',
      );
    }
  }

  static void _validateImageOptions({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) {
    if (imageQuality != null && (imageQuality < 0 || imageQuality > 100)) {
      throw ArgumentError.value(imageQuality, 'imageQuality', 'must be between 0 and 100');
    }
    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth', 'cannot be negative');
    }
    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight', 'cannot be negative');
    }
  }

  static void _validateLimit(int? limit) {
    if (limit != null && limit < 2) {
      throw ArgumentError.value(limit, 'limit', 'cannot be lower than 2');
    }
  }

  int _resolveCount({required bool allowMultiple, int? limit}) {
    if (!allowMultiple) return 1;
    if (_platform.respectsLimit && limit != null) return limit;
    return 3;
  }

  Future<PickedFile> _toPickedFile(XFile file) async => PickedFile(file.path);

  @override
  bool supportsImageSource(ImageSource source) => _platform.supportsImageSource(source);

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) {
    _ensureSourceSupported(source);
    _validateImageOptions(
      maxWidth: options.maxWidth,
      maxHeight: options.maxHeight,
      imageQuality: options.imageQuality,
    );
    return _applyBehavior(null, () => _dataSource.nextImage());
  }

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) {
    return getImageFromSource(
      source: source,
      options: ImagePickerOptions(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
      ),
    );
  }

  @override
  Future<List<XFile>> getMultiImageWithOptions({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) {
    final imageOptions = options.imageOptions;
    _validateImageOptions(
      maxWidth: imageOptions.maxWidth,
      maxHeight: imageOptions.maxHeight,
      imageQuality: imageOptions.imageQuality,
    );
    _validateLimit(options.limit);

    final count = _platform.supportsMultipleSelection
        ? _resolveCount(allowMultiple: true, limit: options.limit)
        : 1;

    return _applyBehavior(<XFile>[], () => _dataSource.nextImages(count));
  }

  @override
  Future<List<XFile>?> getMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final result = await getMultiImageWithOptions(
      options: MultiImagePickerOptions(
        imageOptions: ImageOptions(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        ),
      ),
    );
    return result.isEmpty ? null : result;
  }

  @override
  Future<List<XFile>> getMedia({required MediaOptions options}) {
    final imageOptions = options.imageOptions;
    _validateImageOptions(
      maxWidth: imageOptions.maxWidth,
      maxHeight: imageOptions.maxHeight,
      imageQuality: imageOptions.imageQuality,
    );
    if (!options.allowMultiple && options.limit != null) {
      throw ArgumentError.value(
        options.allowMultiple,
        'allowMultiple',
        'cannot be false when limit is not null',
      );
    }
    _validateLimit(options.limit);

    final count = _resolveCount(
      allowMultiple: options.allowMultiple,
      limit: options.limit,
    );

    return _applyBehavior(<XFile>[], () => _dataSource.nextMedia(count));
  }

  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) {
    _ensureSourceSupported(source);
    return _applyBehavior(null, () => _dataSource.nextVideo());
  }

  @override
  Future<List<XFile>> getMultiVideoWithOptions({
    MultiVideoPickerOptions options = const MultiVideoPickerOptions(),
  }) {
    _validateLimit(options.limit);

    final count = _platform.supportsMultipleSelection
        ? _resolveCount(allowMultiple: true, limit: options.limit)
        : 1;

    return _applyBehavior(<XFile>[], () => _dataSource.nextVideos(count));
  }

  @override
  Future<LostDataResponse> getLostData() {
    if (!_platform.supportsLostData) {
      throw UnimplementedError(
        'retrieveLostData() is only supported on Android.',
      );
    }
    return _applyBehavior(
      LostDataResponse.empty(),
      () => _dataSource.lostData(),
    );
  }

  // Deprecated PickedFile API -------------------------------------------------

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final file = await getImageFromSource(
      source: source,
      options: ImagePickerOptions(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
      ),
    );
    return file != null ? _toPickedFile(file) : null;
  }

  @override
  Future<List<PickedFile>?> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final files = await getMultiImageWithOptions(
      options: MultiImagePickerOptions(
        imageOptions: ImageOptions(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        ),
      ),
    );
    if (files.isEmpty) return null;
    return Future.wait(files.map(_toPickedFile));
  }

  @override
  Future<PickedFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final file = await getVideo(
      source: source,
      preferredCameraDevice: preferredCameraDevice,
      maxDuration: maxDuration,
    );
    return file != null ? _toPickedFile(file) : null;
  }

  @override
  Future<LostData> retrieveLostData() async {
    final response = await getLostData();
    final file = response.file;
    return LostData(
      file: file != null ? await _toPickedFile(file) : null,
      exception: response.exception,
      type: response.type,
    );
  }
}
