package com.github.musicode.photopicker

import android.app.Activity
import android.widget.ImageView
import com.facebook.react.ReactActivity

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.modules.core.PermissionAwareActivity
import com.github.herokotlin.photopicker.PhotoPickerActivity
import com.github.herokotlin.photopicker.PhotoPickerCallback
import com.github.herokotlin.photopicker.PhotoPickerConfiguration
import com.github.herokotlin.photopicker.model.PickedAsset

class RNTPhotoPickerModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "RNTPhotoPicker"
    }

    private var permissionListener = { requestCode: Int, permissions: Array<out String>?, grantResults: IntArray? ->
        if (permissions != null && grantResults != null) {
            PhotoPickerActivity.permission.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
        true
    }

    @ReactMethod
    fun open(options: ReadableMap, promise: Promise) {

        val permission = PhotoPickerActivity.permission

        permission.onExternalStorageNotWritable = {
            promise.reject("3", "external storage is not writable")
        }

        permission.onPermissionsDenied = {
            promise.reject("2", "you denied the requested permissions.")
        }

        permission.onPermissionsNotGranted = {
            promise.reject("1", "has no permissions")
        }

        permission.onRequestPermissions = { activity, list, requestCode ->
            if (activity is ReactActivity) {
                activity.requestPermissions(list, requestCode, permissionListener)
            }
            else if (activity is PermissionAwareActivity) {
                (activity as PermissionAwareActivity).requestPermissions(list, requestCode, permissionListener)
            }
        }

        if (permission.checkExternalStorageWritable()) {
            permission.requestPermissions(currentActivity!!) {
                openActivity(options, promise)
            }
        }

    }

    private fun openActivity(options: ReadableMap, promise: Promise) {

        val configuration = object : PhotoPickerConfiguration() {
            override fun loadAsset(imageView: ImageView, url: String, loading: Int, error: Int, onComplete: (Boolean) -> Unit) {
                loader.invoke(imageView, url, loading, error, onComplete)
            }
        }

        configuration.countable = options.getBoolean("countable")
        configuration.maxSelectCount = options.getInt("maxSelectCount")
        configuration.rawButtonVisible = options.getBoolean("rawButtonVisible")

        if (options.hasKey("imageMinWidth") && options.getInt("imageMinWidth") > 0) {
            configuration.imageMinWidth = options.getInt("imageMinWidth")
        }
        if (options.hasKey("imageMinHeight") && options.getInt("imageMinHeight") > 0) {
            configuration.imageMinHeight = options.getInt("imageMinHeight")
        }
        if (options.hasKey("cancelButtonTitle")) {
            configuration.cancelButtonTitle = options.getString("cancelButtonTitle") as String
        }
        if (options.hasKey("rawButtonTitle")) {
            configuration.rawButtonTitle = options.getString("rawButtonTitle") as String
        }
        if (options.hasKey("submitButtonTitle")) {
            configuration.submitButtonTitle = options.getString("submitButtonTitle") as String
        }

        val callback = object : PhotoPickerCallback {

            override fun onCancel(activity: Activity) {
                activity.finish()
                promise.reject("-1", "cancel")
            }

            override fun onSubmit(activity: Activity, list: List<PickedAsset>) {

                activity.finish()

                val array = Arguments.createArray()

                for (i in list.indices) {
                    val map = Arguments.createMap()
                    val (path, _, width, height, size, isVideo, isRaw) = list[i]

                    map.putString("path", path)
                    map.putInt("size", size)
                    map.putInt("width", width)
                    map.putInt("height", height)
                    map.putBoolean("isVideo", isVideo)
                    map.putBoolean("isRaw", isRaw)

                    array.pushMap(map)
                }

                promise.resolve(array)

            }
        }

        PhotoPickerActivity.configuration = configuration
        PhotoPickerActivity.callback = callback

        PhotoPickerActivity.newInstance(reactContext.currentActivity!!)
    }

    companion object {

        private lateinit var loader: (imageView: ImageView, url: String, loading: Int, error: Int, onComplete: (Boolean) -> Unit) -> Void

        fun setImageLoader(loader: (imageView: ImageView, url: String, loading: Int, error: Int, onComplete: (Boolean) -> Unit) -> Void) {
            this.loader = loader
        }

    }

}