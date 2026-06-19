import 'package:fake_image_picker/fake_image_picker.dart';
import 'package:fake_image_picker_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeImagePickerDemoApp', () {
    tearDown(() {
      FakeImagePicker.unregister();
    });

    testWidgets('displays a fake image path after picking from gallery', (
      tester,
    ) async {
      FakeImagePicker.register();

      await tester.pumpWidget(const FakeImagePickerDemoApp());
      await tester.tap(find.text('Pick image from gallery'));
      await tester.pumpAndSettle();

      expect(find.textContaining('fake:///image_'), findsOneWidget);
    });

    testWidgets('displays cancellation message when picker is cancelled', (
      tester,
    ) async {
      FakeImagePicker.register(
        configuration: FakeImagePickerConfiguration(
          dataSource: EmptyFakeDataSource(),
        ),
      );

      await tester.pumpWidget(const FakeImagePickerDemoApp());
      await tester.tap(find.text('Pick image from gallery'));
      await tester.pumpAndSettle();

      expect(find.text('User cancelled the picker.'), findsOneWidget);
    });
  });
}
