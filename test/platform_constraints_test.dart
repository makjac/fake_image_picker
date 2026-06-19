import 'package:fake_image_picker/fake_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

void main() {
  group('FakePlatformConstraints', () {
    test('Android supports gallery, camera, and lost data', () {
      final platform = FakePlatform.android.constraints;

      expect(platform.supportsImageSource(ImageSource.gallery), isTrue);
      expect(platform.supportsImageSource(ImageSource.camera), isTrue);
      expect(platform.supportsLostData, isTrue);
      expect(platform.supportsCameraDelegate, isFalse);
    });

    test('iOS supports gallery and camera but not lost data', () {
      final platform = FakePlatform.ios.constraints;

      expect(platform.supportsImageSource(ImageSource.gallery), isTrue);
      expect(platform.supportsImageSource(ImageSource.camera), isTrue);
      expect(platform.supportsLostData, isFalse);
    });

    test('macOS supports gallery only by default', () {
      final platform = FakePlatform.macos.constraints;

      expect(platform.supportsImageSource(ImageSource.gallery), isTrue);
      expect(platform.supportsImageSource(ImageSource.camera), isFalse);
      expect(platform.supportsCameraDelegate, isTrue);
    });

    test('Windows supports gallery only by default', () {
      final platform = FakePlatform.windows.constraints;

      expect(platform.supportsImageSource(ImageSource.gallery), isTrue);
      expect(platform.supportsImageSource(ImageSource.camera), isFalse);
    });

    test('Linux supports gallery only by default', () {
      final platform = FakePlatform.linux.constraints;

      expect(platform.supportsImageSource(ImageSource.gallery), isTrue);
      expect(platform.supportsImageSource(ImageSource.camera), isFalse);
    });

    test('web supports gallery and camera but not lost data', () {
      final platform = FakePlatform.web.constraints;

      expect(platform.supportsImageSource(ImageSource.gallery), isTrue);
      expect(platform.supportsImageSource(ImageSource.camera), isTrue);
      expect(platform.supportsLostData, isFalse);
      expect(platform.respectsLimit, isFalse);
    });
  });

  group('platform-specific simulation', () {
    test('camera pick throws on desktop without camera delegate', () async {
      final platform = FakeImagePickerPlatform(
        configuration: FakeImagePickerConfiguration(
          platform: FakePlatform.macos.constraints,
        ),
      );

      await expectLater(
        () => platform.getImageFromSource(source: ImageSource.camera),
        throwsA(isA<PlatformException>()),
      );
    });

    test('web ignores the limit and returns default count', () async {
      final platform = FakeImagePickerPlatform(
        configuration: FakeImagePickerConfiguration(
          platform: FakePlatform.web.constraints,
        ),
      );

      final files = await platform.getMultiImageWithOptions(
        options: const MultiImagePickerOptions(limit: 99),
      );

      expect(files, hasLength(3));
    });

    test('lost data throws on non-Android platforms', () async {
      for (final preset in <FakePlatform>[
        FakePlatform.ios,
        FakePlatform.macos,
        FakePlatform.windows,
        FakePlatform.linux,
        FakePlatform.web,
      ]) {
        final platform = FakeImagePickerPlatform(
          configuration: FakeImagePickerConfiguration(
            platform: preset.constraints,
          ),
        );

        await expectLater(
          () => platform.getLostData(),
          throwsA(isA<UnimplementedError>()),
          reason: 'Expected $preset to throw UnimplementedError',
        );
      }
    });
  });
}
