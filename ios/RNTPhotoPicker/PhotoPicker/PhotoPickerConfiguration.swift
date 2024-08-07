import UIKit
import Photos

@objc open class PhotoPickerConfiguration: NSObject {

    //
    // MARK: - 相册列表
    //

    // 相册单元格默认时的背景色
    @objc public var albumBackgroundColorNormal = UIColor.white

    // 相册单元格按下时的背景色
    @objc public var albumBackgroundColorPressed = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.1)

    // 相册单元格的水平内间距
    @objc public var albumPaddingHorizontal: CGFloat = 12

    // 相册单元格的垂直内间距
    @objc public var albumPaddingVertical: CGFloat = 6

    // 相册封面图的宽度
    @objc public var albumPosterWidth: CGFloat = 50

    // 相册封面图的高度
    @objc public var albumPosterHeight: CGFloat = 50

    // 相册标题字体
    @objc public var albumTitleTextFont = UIFont.systemFont(ofSize: 16)

    // 相册标题颜色
    @objc public var albumTitleTextColor = UIColor.black

    // 相册标题与缩略图的距离
    @objc public var albumTitleMarginLeft: CGFloat = 10

    // 相册数量字体
    @objc public var albumCountTextFont = UIFont.systemFont(ofSize: 14)

    // 相册数量颜色
    @objc public var albumCountTextColor = UIColor.gray

    // 相册数量与标题的距离
    @objc public var albumCountMarginLeft: CGFloat = 10

    // 相册分割线颜色
    @objc public var albumSeparatorColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6)

    // 相册分割线粗细
    @objc public var albumSeparatorThickness = 1 / UIScreen.main.scale

    // 相册向右箭头
    @objc public var albumIndicatorIcon = UIImage(named: "photo_picker_album_indicator")

    //
    // MARK: - 照片网格
    //

    // 网格的背景色
    @objc public var assetGridBackgroundColor = UIColor.white

    // 一行的照片数量
    @objc public var assetGridSpanCount: CGFloat = 3

    // 网格的水平内间距
    @objc public var assetGridPaddingHorizontal: CGFloat = 2

    // 网格的垂直内间距
    @objc public var assetGridPaddingVertical: CGFloat = 2

    // 网格行间距
    @objc public var assetGridRowSpacing: CGFloat = 2

    // 网格列间距
    @objc public var assetGridColumnSpacing: CGFloat = 2


    //
    // MARK: - 计数器
    //

    // 选择按钮宽度
    @objc public var selectButtonWidth: CGFloat = 44

    // 选择按钮高度
    @objc public var selectButtonHeight: CGFloat = 44

    // 选择按钮的图片到顶部的距离
    @objc public var selectButtonImageMarginTop: CGFloat = 5

    // 选择按钮的图片到右边的距离
    @objc public var selectButtonImageMarginRight: CGFloat = 5

    // 选择按钮的标题字体
    @objc public var selectButtonTextFont = UIFont.systemFont(ofSize: 14)

    // 选择按钮的标题颜色
    @objc public var selectButtonTextColor = UIColor.white

    // 未选中时的图片
    @objc public var selectButtonImageUnchecked = UIImage(named: "photo_picker_select_button_unchecked")

    // 选中且不需要计数时的图片
    @objc public var selectButtonImageChecked = UIImage(named: "photo_picker_select_button_checked")

    // 选中且需要计数时的图片
    @objc public var selectButtonImageCheckedCountable = UIImage(named: "photo_picker_select_button_checked_countable")

    //
    // MARK: - 顶部栏
    //

    // 顶部栏高度
    @objc public var topBarHeight: CGFloat = 44

    // 顶部栏水平内间距
    @objc public var topBarPaddingHorizontal: CGFloat = 14

    // 顶部栏背景色
    @objc public var topBarBackgroundColor = UIColor.white

    // 顶部栏边框颜色
    @objc public var topBarBorderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)

    // 顶部栏边框大小
    @objc public var topBarBorderWidth = 1 / UIScreen.main.scale


    //
    // MARK: - 底部栏
    //

    // 底部栏高度
    @objc public var bottomBarHeight: CGFloat = 44

    // 底部栏水平内间距
    @objc public var bottomBarPaddingHorizontal: CGFloat = 14

    // 底部栏背景色
    @objc public var bottomBarBackgroundColor = UIColor(red: 0.15, green: 0.17, blue: 0.20, alpha: 1)

    //
    // MARK: - 取消按钮
    //

    // 取消按钮的标题字体
    @objc public var cancelButtonTextFont = UIFont.systemFont(ofSize: 16)

    // 取消按钮的标题颜色
    @objc public var cancelButtonTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)

    // 取消按钮宽度
    @objc public var cancelButtonMinWidth: CGFloat = 60

    // 取消按钮高度
    @objc public var cancelButtonHeight: CGFloat = 34

    // 取消按钮的标题
    @objc public var cancelButtonTitle = "取消"


    //
    // MARK: - 标题按钮
    //

    // 标题按钮的标题字体
    @objc public var titleButtonTextFont = UIFont.systemFont(ofSize: 18)

    // 标题按钮的标题颜色
    @objc public var titleButtonTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)

    // 标题按钮的图标和文字的距离
    @objc public var titleButtonTitleMarginRight: CGFloat = 5

    // 标题按钮水平内间距，用来扩大点击区域
    @objc public var titleButtonPaddingHorizontal: CGFloat = 8

    // 标题按钮垂直内间距，用来扩大点击区域
    @objc public var titleButtonPaddingVertical: CGFloat = 8

    // 箭头图标
    @objc public var titleButtonArrow = UIImage(named: "photo_picker_arrow")

    //
    // MARK: - 原图按钮
    //

    // 原图按钮的标题字体
    @objc public var originalButtonTextFont = UIFont.systemFont(ofSize: 13)

    // 原图按钮的标题颜色
    @objc public var originalButtonTextColor = UIColor.white

    // 原图按钮的标题到图标的距离
    @objc public var originalButtonTitleMarginLeft: CGFloat = 6

    // 原图按钮水平内间距，用来扩大点击区域
    @objc public var originalButtonPaddingHorizontal: CGFloat = 8

    // 原图按钮垂直内间距，用来扩大点击区域
    @objc public var originalButtonPaddingVertical: CGFloat = 8

    // 原图按钮未选中时的图片
    @objc public var originalButtonImageUnchecked = UIImage(named: "photo_picker_original_button_unchecked")

    // 原图按钮选中时的图片
    @objc public var originalButtonImageChecked = UIImage(named: "photo_picker_original_button_checked")

    // 原图按钮的标题
    @objc public var originalButtonTitle = "原图"

    //
    // MARK: - 确定按钮
    //

    // 确定按钮的标题字体
    @objc public var submitButtonTextFont = UIFont.systemFont(ofSize: 12)

    // 确定按钮的标题颜色
    @objc public var submitButtonTextColor = UIColor.white

    // 确定按钮的背景色
    @objc public var submitButtonBackgroundColorNormal = UIColor(red: 1, green: 0.53, blue: 0.02, alpha: 1)

    // 确定按钮的背景色
    @objc public var submitButtonBackgroundColorPressed = UIColor(red: 1, green: 0.38, blue: 0.04, alpha: 1)

    // 确定按钮的圆角
    @objc public var submitButtonBorderRadius: CGFloat = 4

    // 确定按钮宽度
    @objc public var submitButtonWidth: CGFloat = 66

    // 确定按钮高度
    @objc public var submitButtonHeight: CGFloat = 30

    // 确定按钮的标题
    @objc public var submitButtonTitle = "确定"

    //
    // MARK: - 各种可选配置
    //

    // 是否支持计数
    @objc public var countable = true

    // 最大支持的多选数量
    @objc public var maxSelectCount = 9

    // 图片的最小宽度
    @objc public var imageMinWidth = 0

    // 图片的最小高度
    @objc public var imageMinHeight = 0
    
    // 图片的最大宽度，选中的图片如果超过此宽度，会进行压缩
    @objc public var imageMaxWidth = 0

    // 图片的最大高度，选中的图片如果超过此高度，会进行压缩
    @objc public var imageMaxHeight = 0

    // 是否显示原图按钮
    @objc public var showOriginalButton = false
    
    // 是否需要返回 base64 图片
    @objc public var imageBase64Enabled = false

    //
    // MARK: - 各种选项
    //

    // 相册封面图的加载选项
    @objc public lazy var albumPosterRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        return options
    }()

    // 列表缩略图的加载选项
    @objc public var assetThumbnailRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        return options
    }()

    // 排序字段
    @objc public var assetSortField = "creationDate"

    // 是否正序
    @objc public var assetSortAscending = false

    //
    // MARK: - 各种占位图
    //

    // 相册封面图等待加载时的默认图
    @objc public var albumPosterLoadingPlaceholder = UIImage(named: "photo_picker_album_poster_loading_placeholder")

    // 相册封面图加载错误时的默认图
    @objc public var albumPosterErrorPlaceholder = UIImage(named: "photo_picker_album_poster_error_placeholder")

    // 相册为空时的缩略图
    @objc public var albumEmptyPlaceholder = UIImage(named: "photo_picker_album_empty_placeholder")

    // 照片缩略图等待加载时的默认图
    @objc public var assetThumbnailLoadingPlaceholder = UIImage(named: "photo_picker_asset_thumbnail_loading_placeholder")

    // 照片缩略图加载错误时的默认图
    @objc public var assetThumbnailErrorPlaceholder = UIImage(named: "photo_picker_asset_thumbnail_error_placeholder")

    //
    // MARK: - 照片角标
    //

    // 角标到右边的距离
    @objc public var assetBadgeMarginRight: CGFloat = 5

    // 角标到下边的距离
    @objc public var assetBadgeMarginBottom: CGFloat = 5

    @objc public var assetBadgeGifIcon = UIImage(named: "photo_picker_badge_gif")
    @objc public var assetBadgeLiveIcon = UIImage(named: "photo_picker_badge_live")
    @objc public var assetBadgeWebpIcon = UIImage(named: "photo_picker_badge_webp")

    public override init() {

    }

    open func filter(album: Album) -> Bool {
        // 相册不能按照片数量过滤，因为可能手机被清空过
        // 导致最终一个相册都没有
        return true
    }

    open func filter(asset: Asset) -> Bool {
        if asset.type != .video {
            return asset.width > imageMinWidth && asset.height > imageMinHeight
        }
        return false
    }

}
