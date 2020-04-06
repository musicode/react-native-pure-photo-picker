
import { NativeModules } from 'react-native'

const { RNTPhotoPicker } = NativeModules

export default {

  /**
   *
   * @param {Object} options
   * @property {boolean} options.countable
   * @property {number} options.maxSelectCount
   * @property {boolean} options.rawButtonVisible
   * @property {number} options.imageMinWidth
   * @property {number} options.imageMinHeight
   * @property {string} options.cancelButtonTitle
   * @property {string} options.rawButtonTitle
   * @property {string} options.submitButtonTitle
   * @return {Promise}
   */
  open(options) {
    return RNTPhotoPicker.open(options)
  }

}
