package com.github.musicode.photopicker;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.widget.ImageView;

import com.facebook.react.ReactActivity;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.github.herokotlin.photopicker.PhotoPickerActivity;
import com.github.herokotlin.photopicker.PhotoPickerCallback;
import com.github.herokotlin.photopicker.PhotoPickerConfiguration;
import com.github.herokotlin.photopicker.PhotoPickerManager;
import com.github.herokotlin.photopicker.model.PickedAsset;

import java.util.ArrayList;
import java.util.List;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function2;
import kotlin.jvm.functions.Function5;

public class RNTPhotoPickerModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public RNTPhotoPickerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    private static Function5<ImageView, String, Integer, Integer, Function1, Unit> loader;

    public static void setImageLoader(Function5<ImageView, String, Integer, Integer, Function1, Unit> loader) {
        RNTPhotoPickerModule.loader = loader;
    }

    @Override
    public String getName() {
        return "RNTPhotoPicker";
    }

    @ReactMethod
    public void open(ReadableMap options, final Promise promise) {

        PhotoPickerConfiguration configuration = new PhotoPickerConfiguration() {
            @Override
            public void loadAsset(ImageView imageView, String url, int loading, int error, Function1<? super Boolean, Unit> onComplete) {
                loader.invoke(imageView, url, loading, error, onComplete);
            }

            @Override
            public boolean requestPermissions(Activity activity, List<String> permissions, int requestCode) {
                List<String> list = new ArrayList<>();

                for (String permission: permissions) {
                    if (ContextCompat.checkSelfPermission(activity, permission) != PackageManager.PERMISSION_GRANTED) {
                        list.add(permission);
                    }
                }

                if (list.size() > 0) {
                    ActivityCompat.requestPermissions(activity, list.toArray(new String[list.size()]), requestCode);
                    return false;
                }

                return true;
            }
        };

        configuration.setCountable(options.getBoolean("countable"));
        configuration.setMaxSelectCount(options.getInt("maxSelectCount"));
        configuration.setImageMinWidth(options.getInt("imageMinWidth"));
        configuration.setImageMinHeight(options.getInt("imageMinHeight"));
        configuration.setRawButtonVisible(options.getBoolean("rawButtonVisible"));

        PhotoPickerCallback callback = new PhotoPickerCallback() {

            @Override
            public void onCancel(Activity activity) {
                activity.finish();
                promise.reject("-1", "cancel");
            }

            @Override
            public void onFetchWithoutExternalStorage(Activity activity) {

            }

            @Override
            public void onFetchWithoutPermissions(Activity activity) {

            }

            @Override
            public void onPermissionsDenied(Activity activity) {

            }

            @Override
            public void onPermissionsGranted(Activity activity) {

            }

            @Override
            public void onSubmit(Activity activity, List<PickedAsset> list) {

                activity.finish();

                WritableArray array = Arguments.createArray();

                for (int i = 0; i < list.size(); i++) {
                    WritableMap map = Arguments.createMap();
                    PickedAsset asset = list.get(i);

                    map.putString("path", asset.getPath());
                    map.putInt("size", asset.getSize());
                    map.putInt("width", asset.getWidth());
                    map.putInt("height", asset.getHeight());
                    map.putBoolean("isVideo", asset.isVideo());
                    map.putBoolean("isRaw", asset.isRaw());

                    array.pushMap(map);
                }

                promise.resolve(array);

            }
        };

        PhotoPickerActivity.Companion.setConfiguration(configuration);
        PhotoPickerActivity.Companion.setCallback(callback);

        PhotoPickerActivity.Companion.newInstance(reactContext.getCurrentActivity());

    }

}