import 'dart:typed_data';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// The source of synthetic files used by [FakeImagePickerPlatform].
///
/// Implementations decide whether to return deterministic, random, custom, or
/// empty responses. The platform layer only consumes the returned values.
abstract class FakeImagePickerDataSource {
  /// Returns the next fake image, or `null` to simulate cancellation.
  Future<XFile?> nextImage();

  /// Returns the next fake video, or `null` to simulate cancellation.
  Future<XFile?> nextVideo();

  /// Returns [count] fake images. An empty list simulates cancellation.
  Future<List<XFile>> nextImages(int count);

  /// Returns [count] fake videos. An empty list simulates cancellation.
  Future<List<XFile>> nextVideos(int count);

  /// Returns [count] fake image and/or video files. An empty list simulates
  /// cancellation.
  Future<List<XFile>> nextMedia(int count);

  /// Returns a fake [LostDataResponse].
  ///
  /// The optional [type] hints at what kind of data was lost. Implementations
  /// may ignore it if they already know what to return.
  Future<LostDataResponse> lostData({RetrieveType? type});
}

/// Helpers shared by data source implementations.
abstract final class XFileFactory {
  XFileFactory._();

  static XFile createImage({
    required String path,
    required String name,
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
    DateTime? lastModified,
  }) {
    return XFile.fromData(
      bytes,
      path: path,
      name: name,
      length: bytes.length,
      lastModified: lastModified ?? DateTime(2024, 1, 1),
      mimeType: mimeType,
    );
  }

  static XFile createVideo({
    required String path,
    required String name,
    required Uint8List bytes,
    String mimeType = 'video/mp4',
    DateTime? lastModified,
  }) {
    return XFile.fromData(
      bytes,
      path: path,
      name: name,
      length: bytes.length,
      lastModified: lastModified ?? DateTime(2024, 1, 1),
      mimeType: mimeType,
    );
  }
}
