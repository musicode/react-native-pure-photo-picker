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

Modify `MainApplication.java`

```java

import com.github.musicode.photopicker.RNTPhotoPickerModule;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function5;

public class MainApplication extends Application implements ReactApplication {

  @Override
  public void onCreate() {
    super.onCreate();

    RNTPhotoPickerModule.setImageLoader(
      new Function5<ImageView, String, Integer, Integer, Function1, Unit>() {
        @Override
        public Unit invoke(ImageView imageView, String url, Integer loading, Integer error, Function1 onComplete) {

          // add your image loader here

          return null;
        }
      }
    );
  }

}
```

## Usage

```js
import PhotoPicker from 'react-native-pure-photo-picker'

// 单独判断是否获取到了权限，如果没有，会弹出用户授权对话框
PhotoPicker.requestPermissions()
.then(() => {
  // 获取了权限
})
.catch(error => {
  let { code } = error
  // 1: has no permissions
  // 2: denied the requested permissions
  // 3: external storage is not writable
})

// 包含获取权限 + 打开选择图片的界面
PhotoPicker.open({

  maxSelectCount: 9,
  countable: true,
  rawButtonVisible: true,

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
  rawButtonTitle: '原图',
})
.then(file => {
  let { path, size, width, height, isRaw } = file

})
.catch(error => {
  let { code } = error
  // -1: click cancel button
  // 1: has no permissions
  // 2: denied the requested permissions
  // 3: external storage is not writable
})
```