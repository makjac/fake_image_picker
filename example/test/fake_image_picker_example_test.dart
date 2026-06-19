
import 'package:fake_image_picker/fake_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('ImagePicker unit tests with fake_image_picker', () {
    tearDown(() {
      FakeImagePicker.unregister();
    });

    test('user picks a gallery image', () async {
      FakeImagePicker.register();

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      expect(image, isNotNull);
      expect(image!.path, startsWith('fake:///image_'));
      expect(image.mimeType, 'image/jpeg');
    });

    test('user cancels the image picker', () async {
      FakeImagePicker.register(
        configuration: FakeImagePickerConfiguration(
          dataSource: EmptyFakeDataSource(),
        ),
      );

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      expect(image, isNull);
    });

    test('simulating Android lost data', () async {
      FakeImagePicker.register(
        configuration: FakeImagePickerConfiguration(
          platform: FakePlatform.android.constraints,
        ),
      );

      final picker = ImagePicker();
      final response = await picker.retrieveLostData();

      expect(response.isEmpty, isFalse);
      expect(response.file, isNotNull);
      expect(response.type, isNotNull);
    });

    test('simulating permission denial', () async {
      FakeImagePicker.register(
        configuration: FakeImagePickerConfiguration(
          behavior: FakeImagePickerBehavior(
            platformException: PlatformException(
              code: 'photo_access_denied',
              message: 'User did not allow photo access.',
            ),
          ),
        ),
      );

      final picker = ImagePicker();

      await expectLater(
        () => picker.pickImage(source: ImageSource.gallery),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'photo_access_denied',
          ),
        ),
      );
    });

    test('injected custom files', () async {
      final customFile = XFile.fromData(
        [0xFF, 0xD8].asUint8List(),
        path: 'fake:///my_photo.jpg',
        name: 'my_photo.jpg',
        length: 2,
        mimeType: 'image/jpeg',
      );

      FakeImagePicker.register(
        configuration: FakeImagePickerConfiguration(
          dataSource: CustomFakeDataSource()..queueImage(customFile),
        ),
      );

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      expect(image!.path, 'fake:///my_photo.jpg');
      expect(image.name, 'my_photo.jpg');
    });
  });
}

extension on List<int> {
  Uint8List asUint8List() => Uint8List.fromList(this);
}
