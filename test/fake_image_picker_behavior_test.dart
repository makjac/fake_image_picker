import 'package:fake_image_picker/fake_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

void main() {
  group('FakeImagePickerBehavior', () {
    test('stores all constructor values', () {
      const delay = Duration(milliseconds: 100);
      const exception = FormatException('boom');
      final platformException = PlatformException(code: 'error');
      final behavior = FakeImagePickerBehavior(
        responseDelay: delay,
        autoCancel: true,
        exception: exception,
        platformException: platformException,
        maxSequentialPicks: 5,
      );

      expect(behavior.responseDelay, delay);
      expect(behavior.autoCancel, isTrue);
      expect(behavior.exception, exception);
      expect(behavior.platformException, platformException);
      expect(behavior.maxSequentialPicks, 5);
    });

    test('copyWith replaces responseDelay', () {
      const behavior = FakeImagePickerBehavior(
        responseDelay: Duration(seconds: 1),
      );
      final updated = behavior.copyWith(
        responseDelay: const Duration(seconds: 2),
      );

      expect(updated.responseDelay, const Duration(seconds: 2));
      expect(updated.autoCancel, behavior.autoCancel);
      expect(updated.exception, behavior.exception);
      expect(updated.platformException, behavior.platformException);
      expect(updated.maxSequentialPicks, behavior.maxSequentialPicks);
    });

    test('copyWith replaces autoCancel', () {
      const behavior = FakeImagePickerBehavior(autoCancel: false);
      final updated = behavior.copyWith(autoCancel: true);

      expect(updated.autoCancel, isTrue);
      expect(updated.responseDelay, behavior.responseDelay);
      expect(updated.exception, behavior.exception);
      expect(updated.platformException, behavior.platformException);
      expect(updated.maxSequentialPicks, behavior.maxSequentialPicks);
    });

    test('copyWith replaces exception', () {
      const behavior = FakeImagePickerBehavior();
      final exception = FormatException('x');
      final updated = behavior.copyWith(exception: exception);

      expect(updated.exception, exception);
      expect(updated.responseDelay, behavior.responseDelay);
      expect(updated.autoCancel, behavior.autoCancel);
      expect(updated.platformException, behavior.platformException);
      expect(updated.maxSequentialPicks, behavior.maxSequentialPicks);
    });

    test('copyWith replaces platformException', () {
      const behavior = FakeImagePickerBehavior();
      final exception = PlatformException(code: 'c');
      final updated = behavior.copyWith(platformException: exception);

      expect(updated.platformException, exception);
      expect(updated.responseDelay, behavior.responseDelay);
      expect(updated.autoCancel, behavior.autoCancel);
      expect(updated.exception, behavior.exception);
      expect(updated.maxSequentialPicks, behavior.maxSequentialPicks);
    });

    test('copyWith replaces maxSequentialPicks', () {
      const behavior = FakeImagePickerBehavior(maxSequentialPicks: 1);
      final updated = behavior.copyWith(maxSequentialPicks: 3);

      expect(updated.maxSequentialPicks, 3);
      expect(updated.responseDelay, behavior.responseDelay);
      expect(updated.autoCancel, behavior.autoCancel);
      expect(updated.exception, behavior.exception);
      expect(updated.platformException, behavior.platformException);
    });

    test('copyWith keeps values when no arguments provided', () {
      const behavior = FakeImagePickerBehavior(
        responseDelay: Duration(milliseconds: 50),
        autoCancel: true,
        maxSequentialPicks: 2,
      );
      final updated = behavior.copyWith();

      expect(updated.responseDelay, behavior.responseDelay);
      expect(updated.autoCancel, behavior.autoCancel);
      expect(updated.exception, behavior.exception);
      expect(updated.platformException, behavior.platformException);
      expect(updated.maxSequentialPicks, behavior.maxSequentialPicks);
    });
  });
}
