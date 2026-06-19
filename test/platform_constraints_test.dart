import 'package:fake_image_picker/fake_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

void main() {
  group('FakePlatformConstraints direct', () {
    test('constructs with default values', () {
      const constraints = FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
      );

      expect(constraints.supportedSources, {ImageSource.gallery});
      expect(constraints.supportsLostData, isFalse);
      expect(constraints.supportsCameraDelegate, isFalse);
      expect(constraints.supportsMultipleSelection, isTrue);
      expect(constraints.respectsLimit, isTrue);
    });

    test('constructs with explicit values', () {
      const constraints = FakePlatformConstraints(
        supportedSources: {ImageSource.camera},
        supportsLostData: true,
        supportsCameraDelegate: true,
        supportsMultipleSelection: false,
        respectsLimit: false,
      );

      expect(constraints.supportedSources, {ImageSource.camera});
      expect(constraints.supportsLostData, isTrue);
      expect(constraints.supportsCameraDelegate, isTrue);
      expect(constraints.supportsMultipleSelection, isFalse);
      expect(constraints.respectsLimit, isFalse);
    });

    test('supportsImageSource returns false for unsupported source', () {
      const constraints = FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
      );

      expect(constraints.supportsImageSource(ImageSource.gallery), isTrue);
      expect(constraints.supportsImageSource(ImageSource.camera), isFalse);
    });

    test('copyWith replaces supportedSources', () {
      const constraints = FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
      );
      final updated = constraints.copyWith(
        supportedSources: {ImageSource.camera},
      );

      expect(updated.supportedSources, {ImageSource.camera});
      expect(updated.supportsLostData, constraints.supportsLostData);
      expect(updated.supportsCameraDelegate, constraints.supportsCameraDelegate);
      expect(updated.supportsMultipleSelection, constraints.supportsMultipleSelection);
      expect(updated.respectsLimit, constraints.respectsLimit);
    });

    test('copyWith replaces supportsLostData', () {
      const constraints = FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
      );
      final updated = constraints.copyWith(supportsLostData: true);

      expect(updated.supportsLostData, isTrue);
      expect(updated.supportedSources, constraints.supportedSources);
      expect(updated.supportsCameraDelegate, constraints.supportsCameraDelegate);
      expect(updated.supportsMultipleSelection, constraints.supportsMultipleSelection);
      expect(updated.respectsLimit, constraints.respectsLimit);
    });

    test('copyWith replaces supportsCameraDelegate', () {
      const constraints = FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
      );
      final updated = constraints.copyWith(supportsCameraDelegate: true);

      expect(updated.supportsCameraDelegate, isTrue);
      expect(updated.supportedSources, constraints.supportedSources);
      expect(updated.supportsLostData, constraints.supportsLostData);
      expect(updated.supportsMultipleSelection, constraints.supportsMultipleSelection);
      expect(updated.respectsLimit, constraints.respectsLimit);
    });

    test('copyWith replaces supportsMultipleSelection', () {
      const constraints = FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
      );
      final updated = constraints.copyWith(supportsMultipleSelection: false);

      expect(updated.supportsMultipleSelection, isFalse);
      expect(updated.supportedSources, constraints.supportedSources);
      expect(updated.supportsLostData, constraints.supportsLostData);
      expect(updated.supportsCameraDelegate, constraints.supportsCameraDelegate);
      expect(updated.respectsLimit, constraints.respectsLimit);
    });

    test('copyWith replaces respectsLimit', () {
      const constraints = FakePlatformConstraints(
        supportedSources: {ImageSource.gallery},
      );
      final updated = constraints.copyWith(respectsLimit: false);

      expect(updated.respectsLimit, isFalse);
      expect(updated.supportedSources, constraints.supportedSources);
      expect(updated.supportsLostData, constraints.supportsLostData);
      expect(updated.supportsCameraDelegate, constraints.supportsCameraDelegate);
      expect(updated.supportsMultipleSelection, constraints.supportsMultipleSelection);
    });

    test('copyWith keeps values when no arguments provided', () {
      const constraints = FakePlatformConstraints(
        supportedSources: {ImageSource.camera},
        supportsLostData: true,
        supportsCameraDelegate: true,
        supportsMultipleSelection: false,
        respectsLimit: false,
      );
      final updated = constraints.copyWith();

      expect(updated.supportedSources, constraints.supportedSources);
      expect(updated.supportsLostData, constraints.supportsLostData);
      expect(updated.supportsCameraDelegate, constraints.supportsCameraDelegate);
      expect(updated.supportsMultipleSelection, constraints.supportsMultipleSelection);
      expect(updated.respectsLimit, constraints.respectsLimit);
    });
  });

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
