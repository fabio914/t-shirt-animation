/**
 * @file CGMultiply.js
 * @author runjiatian
 * @date 2022/3/25
 * @brief CGMultiply.js
 * @copyright Copyright (c) 2022, ByteDance Inc, All Rights Reserved
 */

const {BaseNode} = require('./BaseNode');
const Amaz = effect.Amaz;

class CGMultiply extends BaseNode {
  constructor() {
    super();
  }

  setNext(index, func) {
    this.nexts[index] = func;
  }

  setInput(index, func) {
    this.inputs[index] = func;
  }

  getOutput() {
    let curType = this.valueType;
    if (curType == null) {
      return null;
    }

    if (curType == 'Int' || curType == 'Double') {
      let result = 1.0;
      for (let k = 0; k < this.inputs.length; ++k) {
        var op = this.inputs[k]();

        if (op == null) {
          return null;
        }
        result *= op;
      }
      return result;
    } else if (curType == 'Vector2f') {
      let resultX = 1.0;
      let resultY = 1.0;
      for (let k = 0; k < this.inputs.length; ++k) {
        var op = this.inputs[k]();

        if (op == null) {
          return null;
        }
        resultX *= op.x;
        resultY *= op.y;
      }
      return new Amaz.Vector2f(resultX, resultY);
    } else if (curType == 'Vector3f') {
      let resultX = 1.0;
      let resultY = 1.0;
      let resultZ = 1.0;

      for (let k = 0; k < this.inputs.length; ++k) {
        var op = this.inputs[k]();

        if (op == null) {
          return null;
        }
        resultX *= op.x;
        resultY *= op.y;
        resultZ *= op.z;
      }
      return new Amaz.Vector3f(resultX, resultY, resultZ);
    } else if (curType == 'Vector4f') {
      let resultX = 1.0;
      let resultY = 1.0;
      let resultZ = 1.0;
      let resultW = 1.0;

      for (let k = 0; k < this.inputs.length; ++k) {
        var op = this.inputs[k]();

        if (op == null) {
          return null;
        }
        resultX *= op.x;
        resultY *= op.y;
        resultZ *= op.z;
        resultW *= op.w;
      }
      return new Amaz.Vector4f(resultX, resultY, resultZ, resultW);
    } else if (curType == 'Color') {
      let result = 1.0;

      for (let k = 0; k < this.inputs.length; ++k) {
        var op = this.inputs[k]();

        if (op == null) {
          return null;
        }
        result *= op;
      }

      return result;
    }
  }
}

exports.CGMultiply = CGMultiply;
