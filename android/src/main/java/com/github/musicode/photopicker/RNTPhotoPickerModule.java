package com.github.musicode.photopicker;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.widget.ImageView;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.github.herokotlin.photopicker.PhotoPickerActivity;
import com.github.herokotlin.photopicker.PhotoPickerCallback;
import com.github.herokotlin.photopicker.PhotoPickerConfiguration;
import com.github.herokotlin.photopicker.model.PickedAsset;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
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
        configuration.setRawButtonVisible(options.getBoolean("rawButtonVisible"));

        if (options.hasKey("imageMinWidth") && options.getInt("imageMinWidth") > 0) {
            configuration.setImageMinWidth(options.getInt("imageMinWidth"));
        }
        if (options.hasKey("imageMinHeight") && options.getInt("imageMinHeight") > 0) {
            configuration.setImageMinHeight(options.getInt("imageMinHeight"));
        }
        if (options.hasKey("cancelButtonTitle")) {
            configuration.setCancelButtonTitle(options.getString("cancelButtonTitle"));
        }
        if (options.hasKey("rawButtonTitle")) {
            configuration.setRawButtonTitle(options.getString("rawButtonTitle"));
        }
        if (options.hasKey("submitButtonTitle")) {
            configuration.setSubmitButtonTitle(options.getString("submitButtonTitle"));
        }

        PhotoPickerCallback callback = new PhotoPickerCallback() {

            @Override
            public void onCancel(@NotNull Activity activity) {
                activity.finish();
                promise.reject("-1", "cancel");
            }

            @Override
            public void onPermissionsNotGranted(@NotNull Activity activity) {
                activity.finish();
                promise.reject("1", "has no permissions");
            }

            @Override
            public void onPermissionsDenied(@NotNull Activity activity) {
                activity.finish();
                promise.reject("2", "you denied the requested permissions.");
            }

            @Override
            public void onExternalStorageNotWritable(@NotNull Activity activity) {
                activity.finish();
                promise.reject("3", "external storage is not writable");
            }

            @Override
            public void onPermissionsGranted(@NotNull Activity activity) {

            }

            @Override
            public void onSubmit(@NotNull Activity activity, List<PickedAsset> list) {

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