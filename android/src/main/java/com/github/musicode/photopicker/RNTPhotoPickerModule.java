package com.github.musicode.photopicker;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.support.v4.content.ContextCompat;
import android.widget.ImageView;

import com.facebook.react.ReactActivity;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.github.herokotlin.photopicker.PhotoPickerActivity;
import com.github.herokotlin.photopicker.PhotoPickerCallback;
import com.github.herokotlin.photopicker.PhotoPickerConfiguration;
import com.github.herokotlin.photopicker.model.PickedAsset;

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
    public void open(int maxSelectCount, Boolean countable, final Promise promise) {

        PhotoPickerConfiguration configuration = new PhotoPickerConfiguration() {
            @Override
            public void loadAsset(ImageView imageView, String url, int loading, int error, Function1<? super Boolean, Unit> onComplete) {
                loader.invoke(imageView, url, loading, error, onComplete);
            }

            @Override
            public boolean requestPermissions(List<String> permissions, int requestCode) {
                List<String> list = new ArrayList<>();

                Activity activity = reactContext.getCurrentActivity();

                for (String permission: permissions) {
                    if (ContextCompat.checkSelfPermission(activity, permission) != PackageManager.PERMISSION_GRANTED) {
                        list.add(permission);
                    }
                }

                if (list.size() > 0) {
                    if (activity instanceof ReactActivity) {
                        ((ReactActivity)activity).requestPermissions(list.toArray(new String[list.size()]), requestCode, null);
                    }
                    else if (activity instanceof PermissionAwareActivity) {
                        ((PermissionAwareActivity)activity).requestPermissions(list.toArray(new String[list.size()]), requestCode, null);
                    }
                    return false;
                }

                return true;
            }
        };
        configuration.setMaxSelectCount(maxSelectCount);
        configuration.setCountable(countable);

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
                    map.putBoolean("isRaw", asset.isFull());

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