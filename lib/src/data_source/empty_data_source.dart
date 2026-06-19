import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'fake_data_source.dart';

/// A data source that always simulates cancellation.
///
/// Single picks return `null`, multi picks return an empty list, and lost-data
/// returns an empty response.
class EmptyFakeDataSource implements FakeImagePickerDataSource {
  @override
  Future<XFile?> nextImage() async => null;

  @override
  Future<XFile?> nextVideo() async => null;

  @override
  Future<List<XFile>> nextImages(int count) async => const <XFile>[];

  @override
  Future<List<XFile>> nextVideos(int count) async => const <XFile>[];

  @override
  Future<List<XFile>> nextMedia(int count) async => const <XFile>[];

  @override
  Future<LostDataResponse> lostData({RetrieveType? type}) async =>
      LostDataResponse.empty();
}
