import 'dart:typed_data';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'fake_data_source.dart';

/// A deterministic data source that returns synthetic images and videos.
///
/// The generated files live only in memory ([XFile.fromData]) so tests never
/// touch the real filesystem. Paths follow the scheme `fake:///image_N.jpg`
/// and `fake:///video_N.mp4`.
class PredefinedFakeDataSource implements FakeImagePickerDataSource {
  /// Creates a data source that returns deterministic fake files.
  ///
  /// [imageBytes] and [videoBytes] can be used to control the exact payload
  /// of every generated file. When omitted, a tiny placeholder payload is used.
  PredefinedFakeDataSource({
    this.imageBytes,
    this.videoBytes,
  });

  final Uint8List? imageBytes;
  final Uint8List? videoBytes;

  int _imageCounter = 0;
  int _videoCounter = 0;
  int _mediaCounter = 0;

  Uint8List get _defaultImageBytes => Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF]);
  Uint8List get _defaultVideoBytes => Uint8List.fromList(<int>[0x00, 0x00, 0x00, 0x18]);

  @override
  Future<XFile?> nextImage() async {
    _imageCounter++;
    final bytes = imageBytes ?? _defaultImageBytes;
    return XFileFactory.createImage(
      path: 'fake:///image_$_imageCounter.jpg',
      name: 'image_$_imageCounter.jpg',
      bytes: bytes,
      mimeType: 'image/jpeg',
    );
  }

  @override
  Future<XFile?> nextVideo() async {
    _videoCounter++;
    final bytes = videoBytes ?? _defaultVideoBytes;
    return XFileFactory.createVideo(
      path: 'fake:///video_$_videoCounter.mp4',
      name: 'video_$_videoCounter.mp4',
      bytes: bytes,
      mimeType: 'video/mp4',
    );
  }

  @override
  Future<List<XFile>> nextImages(int count) async {
    return Future.wait(List.generate(count, (_) async => (await nextImage())!));
  }

  @override
  Future<List<XFile>> nextVideos(int count) async {
    return Future.wait(List.generate(count, (_) async => (await nextVideo())!));
  }

  @override
  Future<List<XFile>> nextMedia(int count) async {
    final result = <XFile>[];
    for (var i = 0; i < count; i++) {
      _mediaCounter++;
      final isImage = _mediaCounter % 2 == 1;
      result.add(
        isImage
            ? XFileFactory.createImage(
                path: 'fake:///media_$_mediaCounter.jpg',
                name: 'media_$_mediaCounter.jpg',
                bytes: imageBytes ?? _defaultImageBytes,
              )
            : XFileFactory.createVideo(
                path: 'fake:///media_$_mediaCounter.mp4',
                name: 'media_$_mediaCounter.mp4',
                bytes: videoBytes ?? _defaultVideoBytes,
              ),
      );
    }
    return result;
  }

  @override
  Future<LostDataResponse> lostData({RetrieveType? type}) async {
    final effectiveType = type ?? RetrieveType.image;
    final file = effectiveType == RetrieveType.video
        ? await nextVideo()
        : await nextImage();
    return LostDataResponse(
      file: file,
      exception: null,
      type: effectiveType,
      files: file != null ? [file] : null,
    );
  }
}
