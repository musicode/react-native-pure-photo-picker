package com.example;

import android.app.Application;
import android.graphics.Bitmap;
import android.support.annotation.Nullable;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.Target;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;
import com.github.musicode.photopicker.RNTPhotoPickerModule;
import com.github.musicode.photopicker.RNTPhotoPickerPackage;

import java.util.Arrays;
import java.util.List;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function5;

public class MainApplication extends Application implements ReactApplication {

  private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
    @Override
    public boolean getUseDeveloperSupport() {
      return BuildConfig.DEBUG;
    }

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
          new MainReactPackage(),
          new RNTPhotoPickerPackage()
      );
    }

    @Override
    protected String getJSMainModuleName() {
      return "index";
    }
  };

  @Override
  public ReactNativeHost getReactNativeHost() {
    return mReactNativeHost;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    SoLoader.init(this, /* native exopackage */ false);

    RNTPhotoPickerModule.setImageLoader(
            new Function5<ImageView, String, Integer, Integer, Function1, Unit>() {
              @Override
              public Unit invoke(ImageView imageView, String url, Integer loading, Integer error, final Function1 onComplete) {

                RequestOptions options = new RequestOptions().placeholder(loading).error(error);

                Glide.with(imageView.getContext()).asBitmap().load(url).apply(options).listener(new RequestListener<Bitmap>() {
                  @Override
                  public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Bitmap> target, boolean isFirstResource) {
                    onComplete.invoke(false);
                    return false;
                  }

                  @Override
                  public boolean onResourceReady(Bitmap resource, Object model, Target<Bitmap> target, DataSource dataSource, boolean isFirstResource) {
                    onComplete.invoke(true);
                    return false;
                  }
                }).into(imageView);

                return null;
              }
            }
    );
  }
}
