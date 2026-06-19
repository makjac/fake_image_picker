import 'dart:typed_data';

import 'package:fake_image_picker/fake_image_picker.dart';
import 'package:test/test.dart';

void main() {
  group('PredefinedFakeDataSource', () {
    test('returns deterministic image paths', () async {
      final source = PredefinedFakeDataSource();

      final first = (await source.nextImage())!;
      final second = (await source.nextImage())!;

      expect(first.path, 'fake:///image_1.jpg');
      expect(second.path, 'fake:///image_2.jpg');
    });

    test('returns deterministic video paths', () async {
      final source = PredefinedFakeDataSource();

      final first = (await source.nextVideo())!;
      final second = (await source.nextVideo())!;

      expect(first.path, 'fake:///video_1.mp4');
      expect(second.path, 'fake:///video_2.mp4');
    });

    test('returns requested number of images', () async {
      final source = PredefinedFakeDataSource();

      final images = await source.nextImages(5);

      expect(images, hasLength(5));
    });

    test('returns a LostDataResponse with the next image', () async {
      final source = PredefinedFakeDataSource();

      final response = await source.lostData(type: RetrieveType.image);

      expect(response.file, isNotNull);
      expect(response.type, RetrieveType.image);
      expect(response.files, hasLength(1));
    });
  });

  group('RandomFakeDataSource', () {
    test('returns different data with no seed', () async {
      final source = RandomFakeDataSource();

      final first = (await source.nextImage())!;
      final second = (await source.nextImage())!;

      expect(first.path, isNot(equals(second.path)));
    });

    test('is reproducible with the same seed', () async {
      const seed = 42;
      final sourceA = RandomFakeDataSource(seed: seed);
      final sourceB = RandomFakeDataSource(seed: seed);

      final a = (await sourceA.nextImage())!;
      final b = (await sourceB.nextImage())!;

      expect(a.path, equals(b.path));
      expect(await a.length(), equals(await b.length()));
    });

    test('returns mixed media', () async {
      final source = RandomFakeDataSource(seed: 123);

      final media = await source.nextMedia(10);

      expect(media, hasLength(10));
      expect(
        media.any((f) => f.mimeType?.startsWith('image/') ?? false),
        isTrue,
      );
      expect(
        media.any((f) => f.mimeType?.startsWith('video/') ?? false),
        isTrue,
      );
    });

    test('returns a fake video', () async {
      final source = RandomFakeDataSource(seed: 42);

      final video = (await source.nextVideo())!;

      expect(video.path, startsWith('fake:///file_'));
      expect(video.mimeType, startsWith('video/'));
      expect(video.name, endsWith(video.path.split('.').last));
    });

    test('returns lost data with explicit image type', () async {
      final source = RandomFakeDataSource(seed: 123);

      final response = await source.lostData(type: RetrieveType.image);

      expect(response.file, isNotNull);
      expect(response.type, RetrieveType.image);
      expect(response.file!.mimeType, startsWith('image/'));
    });

    test('returns lost data with explicit video type', () async {
      final source = RandomFakeDataSource(seed: 123);

      final response = await source.lostData(type: RetrieveType.video);

      expect(response.file, isNotNull);
      expect(response.type, RetrieveType.video);
      expect(response.file!.mimeType, startsWith('video/'));
    });
  });

  group('CustomFakeDataSource', () {
    test('returns queued responses', () async {
      final source = CustomFakeDataSource()
        ..queueImage(_xFile('custom_1.jpg'))
        ..queueImage(_xFile('custom_2.jpg'));

      final first = (await source.nextImage())!;
      final second = (await source.nextImage())!;

      expect(first.path, 'custom_1.jpg');
      expect(second.path, 'custom_2.jpg');
    });

    test('returns fallback when queue is empty', () async {
      final fallback = _xFile('fallback.jpg');
      final source = CustomFakeDataSource(defaultImage: fallback);

      final file = (await source.nextImage())!;

      expect(file.path, 'fallback.jpg');
    });

    test('queues errors to throw on next call', () async {
      final source = CustomFakeDataSource()..queueError(StateError('boom'));

      await expectLater(
        () => source.nextImage(),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'boom')),
      );
    });

    test('returns queued lists for multi-image', () async {
      final source = CustomFakeDataSource()
        ..queueImages([_xFile('a.jpg'), _xFile('b.jpg')]);

      final files = await source.nextImages(999);

      expect(files, hasLength(2));
    });

    test('returns queued video', () async {
      final source = CustomFakeDataSource()..queueVideo(_xFile('custom.mp4'));

      final file = (await source.nextVideo())!;

      expect(file.path, 'custom.mp4');
    });

    test('returns fallback video when queue is empty', () async {
      final fallback = _xFile('fallback_video.mp4');
      final source = CustomFakeDataSource(defaultVideo: fallback);

      final file = (await source.nextVideo())!;

      expect(file.path, 'fallback_video.mp4');
    });

    test('returns queued lists for multi-video', () async {
      final source = CustomFakeDataSource()
        ..queueVideos([_xFile('a.mp4'), _xFile('b.mp4')]);

      final files = await source.nextVideos(999);

      expect(files, hasLength(2));
    });

    test('returns queued media', () async {
      final source = CustomFakeDataSource()
        ..queueMedia([_xFile('a.jpg'), _xFile('b.mp4')]);

      final files = await source.nextMedia(999);

      expect(files, hasLength(2));
    });

    test('returns queued lost data', () async {
      final response = LostDataResponse(
        file: _xFile('lost.jpg'),
        exception: null,
        type: RetrieveType.image,
        files: [_xFile('lost.jpg')],
      );
      final source = CustomFakeDataSource()..queueLostData(response);

      final result = await source.lostData();

      expect(result.file, isNotNull);
      expect(result.type, RetrieveType.image);
    });

    test('returns default lost data when queue is empty', () async {
      final defaultResponse = LostDataResponse(
        file: _xFile('default_lost.jpg'),
        exception: null,
        type: RetrieveType.video,
        files: [_xFile('default_lost.jpg')],
      );
      final source = CustomFakeDataSource(defaultLostData: defaultResponse);

      final result = await source.lostData();

      expect(result.file, isNotNull);
      expect(result.type, RetrieveType.video);
    });
  });

  group('EmptyFakeDataSource', () {
    test('always returns null or empty', () async {
      final source = EmptyFakeDataSource();

      expect(await source.nextImage(), isNull);
      expect(await source.nextVideo(), isNull);
      expect(await source.nextImages(3), isEmpty);
      expect(await source.nextVideos(3), isEmpty);
      expect(await source.nextMedia(3), isEmpty);
      expect((await source.lostData()).isEmpty, isTrue);
    });
  });
}

XFile _xFile(String path) => XFile.fromData(
  Uint8List.fromList(<int>[0xFF, 0xD8]),
  path: path,
  name: path,
  length: 2,
);
