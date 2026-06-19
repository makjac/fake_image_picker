import 'package:fake_image_picker/fake_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

void main() {
  group('FakeImagePickerPlatform', () {
    late FakeImagePickerPlatform platform;

    setUp(() {
      platform = FakeImagePickerPlatform();
    });

    group('getImageFromSource', () {
      test('returns a fake image from gallery', () async {
        final file = await platform.getImageFromSource(
          source: ImageSource.gallery,
        );

        expect(file, isNotNull);
        expect(file!.path, startsWith('fake:///image_'));
        expect(file.name, startsWith('image_'));
        expect(file.mimeType, 'image/jpeg');
      });

      test('returns a fake image from camera', () async {
        final file = await platform.getImageFromSource(
          source: ImageSource.camera,
        );

        expect(file, isNotNull);
        expect(file!.path, startsWith('fake:///image_'));
      });

      test('returns null when data source cancels', () async {
        platform.configuration = platform.configuration.copyWith(
          dataSource: EmptyFakeDataSource(),
        );

        final file = await platform.getImageFromSource(
          source: ImageSource.gallery,
        );

        expect(file, isNull);
      });

      test('throws ArgumentError for invalid imageQuality', () async {
        await expectLater(
          () => platform.getImageFromSource(
            source: ImageSource.gallery,
            options: const ImagePickerOptions(imageQuality: 150),
          ),
          throwsArgumentError,
        );
      });
    });

    group('getMultiImageWithOptions', () {
      test('returns multiple fake images', () async {
        final files = await platform.getMultiImageWithOptions(
          options: const MultiImagePickerOptions(limit: 3),
        );

        expect(files, hasLength(3));
        expect(files.every((f) => f.mimeType == 'image/jpeg'), isTrue);
      });

      test('throws ArgumentError when limit is below 2', () async {
        await expectLater(
          () => platform.getMultiImageWithOptions(
            options: const MultiImagePickerOptions(limit: 1),
          ),
          throwsArgumentError,
        );
      });
    });

    group('getVideo', () {
      test('returns a fake video', () async {
        final file = await platform.getVideo(source: ImageSource.gallery);

        expect(file, isNotNull);
        expect(file!.path, startsWith('fake:///video_'));
        expect(file.mimeType, 'video/mp4');
      });
    });

    group('getMultiVideoWithOptions', () {
      test('returns multiple fake videos', () async {
        final files = await platform.getMultiVideoWithOptions(
          options: const MultiVideoPickerOptions(limit: 2),
        );

        expect(files, hasLength(2));
        expect(files.every((f) => f.mimeType == 'video/mp4'), isTrue);
      });
    });

    group('getMedia', () {
      test('returns a single media item when allowMultiple is false', () async {
        final files = await platform.getMedia(
          options: MediaOptions.createAndValidate(
            allowMultiple: false,
            imageOptions: const ImageOptions(),
          ),
        );

        expect(files, hasLength(1));
      });

      test('returns multiple media items when allowMultiple is true', () async {
        final files = await platform.getMedia(
          options: MediaOptions.createAndValidate(
            allowMultiple: true,
            limit: 4,
            imageOptions: const ImageOptions(),
          ),
        );

        expect(files, hasLength(4));
      });

      test('throws ArgumentError when allowMultiple is false and limit is set',
          () async {
        await expectLater(
          () => platform.getMedia(
            options: MediaOptions.createAndValidate(
              allowMultiple: false,
              limit: 2,
              imageOptions: const ImageOptions(),
            ),
          ),
          throwsArgumentError,
        );
      });
    });

    group('getLostData', () {
      test('returns a fake lost data response on Android', () async {
        platform.configuration = platform.configuration.copyWith(
          platform: FakePlatform.android.constraints,
        );

        final response = await platform.getLostData();

        expect(response.isEmpty, isFalse);
        expect(response.file, isNotNull);
        expect(response.type, isNotNull);
      });

      test('throws UnimplementedError on iOS', () async {
        platform.configuration = platform.configuration.copyWith(
          platform: FakePlatform.ios.constraints,
        );

        await expectLater(
          () => platform.getLostData(),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('supportsImageSource', () {
      test('returns true for gallery and camera on universal platform', () {
        expect(platform.supportsImageSource(ImageSource.gallery), isTrue);
        expect(platform.supportsImageSource(ImageSource.camera), isTrue);
      });
    });

    group('behavior injection', () {
      test('delays responses', () async {
        platform.configuration = platform.configuration.copyWith(
          behavior: const FakeImagePickerBehavior(
            responseDelay: Duration(milliseconds: 50),
          ),
        );

        final stopwatch = Stopwatch()..start();
        await platform.getImageFromSource(source: ImageSource.gallery);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(40));
      });

      test('throws PlatformException when configured', () async {
        platform.configuration = platform.configuration.copyWith(
          behavior: FakeImagePickerBehavior(
            platformException: PlatformException(
              code: 'permission_denied',
              message: 'User denied permission',
            ),
          ),
        );

        await expectLater(
          () => platform.getImageFromSource(source: ImageSource.gallery),
          throwsA(
            isA<PlatformException>().having((e) => e.code, 'code', 'permission_denied'),
          ),
        );
      });

      test('auto-cancels every call', () async {
        platform.configuration = platform.configuration.copyWith(
          behavior: const FakeImagePickerBehavior(autoCancel: true),
        );

        final image = await platform.getImageFromSource(source: ImageSource.gallery);
        final images = await platform.getMultiImageWithOptions();
        final video = await platform.getVideo(source: ImageSource.gallery);

        expect(image, isNull);
        expect(images, isEmpty);
        expect(video, isNull);
      });

      test('simulates plugin already in use after N picks', () async {
        platform.configuration = platform.configuration.copyWith(
          behavior: const FakeImagePickerBehavior(maxSequentialPicks: 1),
        );

        await platform.getImageFromSource(source: ImageSource.gallery);

        await expectLater(
          () => platform.getImageFromSource(source: ImageSource.gallery),
          throwsA(
            isA<PlatformException>().having((e) => e.code, 'code', 'already_active'),
          ),
        );
      });
    });

    group('deprecated PickedFile API', () {
      test('pickImage returns a PickedFile', () async {
        final file = await platform.pickImage(source: ImageSource.gallery);

        expect(file, isNotNull);
        expect(file!.path, startsWith('fake:///image_'));
      });

      test('pickMultiImage returns a list of PickedFiles', () async {
        final files = await platform.pickMultiImage();

        expect(files, isNotNull);
        expect(files, hasLength(3));
      });

      test('pickVideo returns a PickedFile', () async {
        final file = await platform.pickVideo(source: ImageSource.gallery);

        expect(file, isNotNull);
        expect(file!.path, startsWith('fake:///video_'));
      });

      test('retrieveLostData returns a LostData object', () async {
        platform.configuration = platform.configuration.copyWith(
          platform: FakePlatform.android.constraints,
        );

        final lostData = await platform.retrieveLostData();

        expect(lostData.isEmpty, isFalse);
        expect(lostData.file, isNotNull);
      });
    });
  });
}
