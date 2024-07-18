
import { NativeModules } from 'react-native'

const { RNTPhotoPicker } = NativeModules

export default {

  /**
   *
   * @param {Object} options
   * @property {boolean} options.countable
   * @property {number} options.maxSelectCount
   * @property {boolean} options.showOriginalButton
   * @property {boolean} options.imageBase64Enabled
   * @property {number} options.imageMinWidth
   * @property {number} options.imageMinHeight
   * @property {string} options.cancelButtonTitle
   * @property {string} options.originalButtonTitle
   * @property {string} options.submitButtonTitle
   * @return {Promise}
   */
  open(options) {
    return RNTPhotoPicker.open(options)
  }

}
