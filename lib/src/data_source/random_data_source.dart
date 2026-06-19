import 'dart:math';
import 'dart:typed_data';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'fake_data_source.dart';

/// A data source that returns randomized fake files on every call.
///
/// Use this when you want to ensure your code does not depend on hard-coded
/// fake values.
class RandomFakeDataSource implements FakeImagePickerDataSource {
  /// Creates a random data source.
  ///
  /// [seed] makes the output reproducible across test runs.
  RandomFakeDataSource({int? seed}) : _random = Random(seed);

  final Random _random;

  static const _imageExtensions = <String>['jpg', 'png', 'webp', 'heic'];
  static const _videoExtensions = <String>['mp4', 'mov', 'webm'];

  Uint8List _randomBytes(int min, int max) {
    final length = min + _random.nextInt(max - min + 1);
    return Uint8List.fromList(
      List.generate(length, (_) => _random.nextInt(256)),
    );
  }

  String _randomName(List<String> extensions) {
    final prefix = _random.nextInt(1 << 32).toRadixString(16);
    final suffix = _random.nextInt(9999).toString().padLeft(4, '0');
    final ext = extensions[_random.nextInt(extensions.length)];
    return 'file_${prefix}_$suffix.$ext';
  }

  @override
  Future<XFile?> nextImage() async {
    final bytes = _randomBytes(64, 4096);
    final name = _randomName(_imageExtensions);
    return XFileFactory.createImage(
      path: 'fake:///$name',
      name: name,
      bytes: bytes,
      mimeType: 'image/${name.split('.').last}',
    );
  }

  @override
  Future<XFile?> nextVideo() async {
    final bytes = _randomBytes(1024, 8192);
    final name = _randomName(_videoExtensions);
    return XFileFactory.createVideo(
      path: 'fake:///$name',
      name: name,
      bytes: bytes,
      mimeType: 'video/${name.split('.').last}',
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
    return Future.wait(
      List.generate(
        count,
        (_) async =>
            _random.nextBool() ? (await nextImage())! : (await nextVideo())!,
      ),
    );
  }

  @override
  Future<LostDataResponse> lostData({RetrieveType? type}) async {
    final effectiveType =
        type ?? (_random.nextBool() ? RetrieveType.image : RetrieveType.video);
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
