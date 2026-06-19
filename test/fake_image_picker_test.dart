import 'package:fake_image_picker/fake_image_picker.dart';
import 'package:test/test.dart';

void main() {
  group('FakeImagePicker.register / unregister', () {
    tearDown(() {
      FakeImagePicker.unregister();
    });

    test('replaces ImagePickerPlatform.instance', () {
      final original = ImagePickerPlatform.instance;

      FakeImagePicker.register();

      expect(ImagePickerPlatform.instance, isA<FakeImagePickerPlatform>());
      expect(
        ImagePickerPlatform.instance,
        equals(FakeImagePicker.registeredPlatform),
      );

      FakeImagePicker.unregister();

      expect(ImagePickerPlatform.instance, equals(original));
      expect(FakeImagePicker.registeredPlatform, isNull);
    });

    test('custom configuration is used by registered platform', () async {
      FakeImagePicker.register(
        configuration: FakeImagePickerConfiguration(
          platform: FakePlatform.ios.constraints,
          dataSource: EmptyFakeDataSource(),
        ),
      );

      final picker = FakeImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);

      expect(file, isNull);
    });

    test('re-registering restores and replaces again', () {
      final original = ImagePickerPlatform.instance;

      FakeImagePicker.register();
      final first = FakeImagePicker.registeredPlatform;
      FakeImagePicker.register();
      final second = FakeImagePicker.registeredPlatform;

      expect(first, isNot(equals(second)));
      expect(ImagePickerPlatform.instance, equals(second));

      FakeImagePicker.unregister();
      expect(ImagePickerPlatform.instance, equals(original));
    });
  });

  group('FakeImagePicker facade', () {
    late FakeImagePickerPlatform platform;
    late FakeImagePicker picker;

    setUp(() {
      platform = FakeImagePickerPlatform();
      picker = FakeImagePicker(platform: platform);
    });

    test('pickImage delegates to platform', () async {
      final file = await picker.pickImage(source: ImageSource.gallery);

      expect(file, isNotNull);
    });

    test('pickMultiImage delegates to platform', () async {
      final files = await picker.pickMultiImage(limit: 2);

      expect(files, hasLength(2));
    });

    test('pickMedia returns a single item', () async {
      final file = await picker.pickMedia();

      expect(file, isNotNull);
    });

    test('pickMultipleMedia returns multiple items', () async {
      final files = await picker.pickMultipleMedia(limit: 3);

      expect(files, hasLength(3));
    });

    test('pickVideo delegates to platform', () async {
      final file = await picker.pickVideo(source: ImageSource.gallery);

      expect(file, isNotNull);
    });

    test('pickMultiVideo delegates to platform', () async {
      final files = await picker.pickMultiVideo(limit: 2);

      expect(files, hasLength(2));
    });

    test('supportsImageSource delegates to platform', () {
      expect(picker.supportsImageSource(ImageSource.gallery), isTrue);
    });
  });
}
