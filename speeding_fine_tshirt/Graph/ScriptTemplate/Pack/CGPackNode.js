/**
 * @file CGPackNode.js
 * @author Weifeng Huang (huangweifeng.2067@bytedance.com)
 * @date 2021-08-26
 * @brief
 * @copyright Copyright (c) 2021, ByteDance Inc, All Rights Reserved
 */
const {BaseNode} = require('./BaseNode');
const Amaz = effect.Amaz;

class CGPackNode extends BaseNode {
  constructor() {
    super();
    this.valueType = null;
  }

  getOutput(index) {
    if (this.valueType === 'Vector2f') {
      return new Amaz.Vector2f(this.inputs[0](), this.inputs[1]());
    } else if (this.valueType === 'Vector3f') {
      return new Amaz.Vector3f(this.inputs[0](), this.inputs[1](), this.inputs[2]());
    } else if (this.valueType === 'Vector4f') {
      return new Amaz.Vector4f(this.inputs[0](), this.inputs[1](), this.inputs[2](), this.inputs[3]());
    } else if (this.valueType === 'Quaternionf') {
      return new Amaz.Quaternionf(this.inputs[0](), this.inputs[1](), this.inputs[2](), this.inputs[3]());
    } else if (this.valueType === 'Rect') {
      return new Amaz.Rect(this.inputs[0](), this.inputs[1](), this.inputs[2](), this.inputs[3]());
    } else if (this.valueType === 'Color') {
      return new Amaz.Color(this.inputs[0](), this.inputs[1](), this.inputs[2](), this.inputs[3]());
    }
  }
}

exports.CGPackNode = CGPackNode;
