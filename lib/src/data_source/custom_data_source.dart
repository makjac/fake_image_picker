import 'dart:collection';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'fake_data_source.dart';

/// A data source where every response is supplied by the test author.
///
/// Use this to reproduce exact scenarios: specific files, specific
/// cancellation points, specific [LostDataResponse] values, and specific
/// exceptions.
///
/// ```dart
/// final source = CustomFakeDataSource()
///   ..queueImage(myXFile)
///   ..queueVideo(null)
///   ..queueImages([file1, file2]);
/// ```
class CustomFakeDataSource implements FakeImagePickerDataSource {
  /// Creates a custom data source with optional fallback values.
  CustomFakeDataSource({
    XFile? defaultImage,
    XFile? defaultVideo,
    List<XFile>? defaultImages,
    List<XFile>? defaultVideos,
    List<XFile>? defaultMedia,
    LostDataResponse? defaultLostData,
  }) : _defaultImage = defaultImage,
       _defaultVideo = defaultVideo,
       _defaultImages = defaultImages ?? const <XFile>[],
       _defaultVideos = defaultVideos ?? const <XFile>[],
       _defaultMedia = defaultMedia ?? const <XFile>[],
       _defaultLostData = defaultLostData ?? LostDataResponse.empty();

  final Queue<XFile?> _images = Queue<XFile?>();
  final Queue<XFile?> _videos = Queue<XFile?>();
  final Queue<List<XFile>> _imagesList = Queue<List<XFile>>();
  final Queue<List<XFile>> _videosList = Queue<List<XFile>>();
  final Queue<List<XFile>> _mediaList = Queue<List<XFile>>();
  final Queue<LostDataResponse> _lostData = Queue<LostDataResponse>();

  final XFile? _defaultImage;
  final XFile? _defaultVideo;
  final List<XFile> _defaultImages;
  final List<XFile> _defaultVideos;
  final List<XFile> _defaultMedia;
  final LostDataResponse _defaultLostData;

  Object? _pendingError;

  /// Queues an [XFile?] to be returned by the next single-image pick.
  void queueImage(XFile? file) => _images.add(file);

  /// Queues an [XFile?] to be returned by the next single-video pick.
  void queueVideo(XFile? file) => _videos.add(file);

  /// Queues a list to be returned by the next multi-image pick.
  void queueImages(List<XFile> files) => _imagesList.add(files);

  /// Queues a list to be returned by the next multi-video pick.
  void queueVideos(List<XFile> files) => _videosList.add(files);

  /// Queues a list to be returned by the next mixed-media pick.
  void queueMedia(List<XFile> files) => _mediaList.add(files);

  /// Queues a [LostDataResponse] to be returned by the next lost-data call.
  void queueLostData(LostDataResponse response) => _lostData.add(response);

  /// Throws [error] on the very next data-source call, then clears it.
  ///
  /// This is a convenience for simulating failures that come from the data
  /// layer. Platform-level errors can also be configured through
  /// [FakeImagePickerBehavior].
  void queueError(Object error) => _pendingError = error;

  void _throwIfPending() {
    final error = _pendingError;
    if (error != null) {
      _pendingError = null;
      throw error;
    }
  }

  T _next<T>(Queue<T> queue, T fallback) {
    _throwIfPending();
    return queue.isEmpty ? fallback : queue.removeFirst();
  }

  @override
  Future<XFile?> nextImage() async => _next(_images, _defaultImage);

  @override
  Future<XFile?> nextVideo() async => _next(_videos, _defaultVideo);

  @override
  Future<List<XFile>> nextImages(int count) async =>
      _next(_imagesList, _defaultImages);

  @override
  Future<List<XFile>> nextVideos(int count) async =>
      _next(_videosList, _defaultVideos);

  @override
  Future<List<XFile>> nextMedia(int count) async =>
      _next(_mediaList, _defaultMedia);

  @override
  Future<LostDataResponse> lostData({RetrieveType? type}) async =>
      _next(_lostData, _defaultLostData);
}
