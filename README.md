# react-native-pure-photo-picker

This is a module which help you pick an image.

## Installation

```
npm i react-native-pure-photo-picker
// link below 0.60
react-native link react-native-pure-photo-picker
```

## Setup

### iOS

Add `NSPhotoLibraryUsageDescription` in your `ios/${ProjectName}/Info.plist`:

```
<key>NSPhotoLibraryUsageDescription</key>
<string>balabala</string>
```

### Android

Add `jitpack` in your `android/build.gradle` at the end of repositories:

```
allprojects {
  repositories {
    ...
    maven { url 'https://jitpack.io' }
  }
}
```

Modify `MainApplication`

```kotlin
class MainApplication : Application(), ReactApplication {

  override fun onCreate() {
    super.onCreate()

    RNTPhotoPickerModule.init { imageView, url, loading, error, onComplete ->

        // load image to imageView by url
        // onComplete.invoke(false): load error
        // onComplete.invoke(true): load success

    }

  }

}
```

## Usage

```js
import photoPicker from 'react-native-pure-photo-picker'

// At first, make sure you have the permissions.
// ios: PHOTO_LIBRARY
// android: WRITE_EXTERNAL_STORAGE

// If you don't have these permissions, you can't call open method.

// 包含获取权限 + 打开选择图片的界面
photoPicker.open({

  maxSelectCount: 9,
  countable: true,
  showOriginalButton: true,
  imageBase64Enabled: true,

  // filter image by width and height
  // optional
  imageMinWidth: 100,
  // optional
  imageMinHeight: 100,

  // optional
  submitButtonTitle: '确定',
  // optional
  cancelButtonTitle: '取消',
  // optional
  originalButtonTitle: '原图',
})
.then(data => {
  let { path, size, width, height, isOriginal } = data

})
.catch(() => {
  // click cancel button
})
```