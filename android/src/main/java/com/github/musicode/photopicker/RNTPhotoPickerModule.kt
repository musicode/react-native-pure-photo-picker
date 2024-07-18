package com.github.musicode.photopicker

import android.app.Activity
import android.widget.ImageView

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.github.herokotlin.photopicker.PhotoPickerActivity
import com.github.herokotlin.photopicker.PhotoPickerCallback
import com.github.herokotlin.photopicker.PhotoPickerConfiguration
import com.github.herokotlin.photopicker.model.PickedAsset

class RNTPhotoPickerModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    companion object {

        private lateinit var loader: (imageView: ImageView, url: String, loading: Int, error: Int, onComplete: (Boolean) -> Unit) -> Unit

        fun init(loader: (imageView: ImageView, url: String, loading: Int, error: Int, onComplete: (Boolean) -> Unit) -> Unit) {
            this.loader = loader
        }

    }

    override fun getName(): String {
        return "RNTPhotoPicker"
    }

    @ReactMethod
    fun open(options: ReadableMap, promise: Promise) {

        val configuration = object : PhotoPickerConfiguration() {
            override fun loadAsset(imageView: ImageView, url: String, loading: Int, error: Int, onComplete: (Boolean) -> Unit) {
                loader.invoke(imageView, url, loading, error, onComplete)
            }
        }

        configuration.countable = options.getBoolean("countable")
        configuration.maxSelectCount = options.getInt("maxSelectCount")
        configuration.showOriginalButton = options.getBoolean("showOriginalButton")

        if (options.hasKey("imageMinWidth") && options.getInt("imageMinWidth") > 0) {
            configuration.imageMinWidth = options.getInt("imageMinWidth")
        }
        if (options.hasKey("imageMinHeight") && options.getInt("imageMinHeight") > 0) {
            configuration.imageMinHeight = options.getInt("imageMinHeight")
        }
        if (options.hasKey("cancelButtonTitle")) {
            configuration.cancelButtonTitle = options.getString("cancelButtonTitle") as String
        }
        if (options.hasKey("originalButtonTitle")) {
            configuration.originalButtonTitle = options.getString("originalButtonTitle") as String
        }
        if (options.hasKey("submitButtonTitle")) {
            configuration.submitButtonTitle = options.getString("submitButtonTitle") as String
        }

        val callback = object : PhotoPickerCallback {

            override fun onCancel(activity: Activity) {
                activity.finish()
                promise.reject("-1", "cancel")
            }

            override fun onSubmit(activity: Activity, assetList: List<PickedAsset>) {

                activity.finish()

                val array = Arguments.createArray()

                for (i in assetList.indices) {
                    val map = Arguments.createMap()
                    val (path, _, base64, width, height, size, isVideo, isOriginal) = assetList[i]

                    map.putString("path", path)
                    map.putString("base64", base64)
                    map.putInt("size", size)
                    map.putInt("width", width)
                    map.putInt("height", height)
                    map.putBoolean("isVideo", isVideo)
                    map.putBoolean("isOriginal", isOriginal)

                    array.pushMap(map)
                }

                promise.resolve(array)

            }
        }

        PhotoPickerActivity.configuration = configuration
        PhotoPickerActivity.callback = callback

        PhotoPickerActivity.newInstance(reactContext.currentActivity!!)

    }

}
