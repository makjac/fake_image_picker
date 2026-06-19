/// A ready-to-use fake for the Flutter `image_picker` plugin.
///
/// Add `fake_image_picker` to your `dev_dependencies`, call
/// `FakeImagePicker.register()` in `setUp`, and control exactly what your
/// tests receive from the image picker.
library;

export 'package:image_picker_platform_interface/image_picker_platform_interface.dart'
    show
        CameraDevice,
        ImageOptions,
        ImagePickerCameraDelegate,
        ImagePickerCameraDelegateOptions,
        ImagePickerOptions,
        ImagePickerPlatform,
        ImageSource,
        LostData,
        LostDataResponse,
        MediaOptions,
        MediaSelectionType,
        MultiImagePickerOptions,
        MultiVideoPickerOptions,
        PickedFile,
        RetrieveType,
        XFile,
        kTypeImage,
        kTypeMedia,
        kTypeVideo;

export 'src/data_source/custom_data_source.dart';
export 'src/data_source/empty_data_source.dart';
export 'src/data_source/fake_data_source.dart';
export 'src/data_source/predefined_data_source.dart';
export 'src/data_source/random_data_source.dart';
export 'src/fake_image_picker.dart';
export 'src/fake_image_picker_behavior.dart';
export 'src/fake_image_picker_config.dart';
export 'src/fake_image_picker_platform.dart';
export 'src/platform/fake_platform.dart';
export 'src/platform/fake_platform_constraints.dart';
