import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Configurable runtime behavior of the fake picker.
///
/// This is separated from [FakePlatformConstraints] because behavior is about
/// *what happens during a call*, while constraints are about *what the
/// platform is capable of*.
@immutable
class FakeImagePickerBehavior {
  /// Creates behavior settings.
  const FakeImagePickerBehavior({
    this.responseDelay,
    this.autoCancel = false,
    this.exception,
    this.platformException,
    this.maxSequentialPicks,
  });

  /// If set, every call is delayed by this duration.
  final Duration? responseDelay;

  /// When `true`, single picks return `null` and multi picks return an empty
  /// list, regardless of the data source.
  final bool autoCancel;

  /// If set, the next call throws this generic exception.
  final Exception? exception;

  /// If set, the next call throws a [PlatformException] with this payload.
  final PlatformException? platformException;

  /// If set, the mock throws a [PlatformException] with code
  /// `'already_active'` after this many sequential successful picks.
  final int? maxSequentialPicks;

  /// Returns a copy with the supplied fields replaced.
  FakeImagePickerBehavior copyWith({
    Duration? responseDelay,
    bool? autoCancel,
    Exception? exception,
    PlatformException? platformException,
    int? maxSequentialPicks,
  }) {
    return FakeImagePickerBehavior(
      responseDelay: responseDelay ?? this.responseDelay,
      autoCancel: autoCancel ?? this.autoCancel,
      exception: exception ?? this.exception,
      platformException: platformException ?? this.platformException,
      maxSequentialPicks: maxSequentialPicks ?? this.maxSequentialPicks,
    );
  }
}
