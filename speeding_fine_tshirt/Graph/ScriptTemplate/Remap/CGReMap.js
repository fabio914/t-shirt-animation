/**
 * @file CGMap.js
 * @author liujiacheng
 * @date 2021/8/23
 * @brief CGMap.js
 * @copyright Copyright (c) 2021, ByteDance Inc, All Rights Reserved
 */

const {BaseNode} = require('./BaseNode');
const Amaz = effect.Amaz;

class CGReMap extends BaseNode {
  constructor() {
    super();
  }

  setNext(index, func) {
    this.nexts[index] = func;
  }

  setInput(index, func) {
    this.inputs[index] = func;
  }

  getOutput(index) {
    let inputVal = this.inputs[0]();
    let inputMin = this.inputs[1]();
    let inputMax = this.inputs[2]();
    let outputMin = this.inputs[3]();
    let outputMax = this.inputs[4]();
    let isClamp = this.inputs[5]();
    let FLT_EPSILON = 1.1920929e-7;

    if (
      inputVal == null ||
      inputMin == null ||
      inputMax == null ||
      outputMin == null ||
      outputMax == null ||
      isClamp == null
    ) {
      return null;
    }

    if (Math.abs(inputMin - inputMax) < FLT_EPSILON) {
      return outputMin;
    } else {
      let outputVal = ((inputVal - inputMin) / (inputMax - inputMin)) * (outputMax - outputMin) + outputMin;
      if (isClamp) {
        if (outputMax < outputMin) {
          if (outputVal < outputMax) {
            outputVal = outputMax;
          } else if (outputVal > outputMin) {
            outputVal = outputMin;
          }
        } else {
          if (outputVal > outputMax) {
            outputVal = outputMax;
          } else if (outputVal < outputMin) {
            outputVal = outputMin;
          }
        }
      }
      return outputVal;
    }
  }
}

exports.CGReMap = CGReMap;
