/**
 * @file CGRunTime.js
 * @author liujiacheng
 * @date 2021/8/20
 * @brief CGRunTime.js
 * @copyright Copyright (c) 2021, ByteDance Inc, All Rights Reserved
 */

const {BaseNode} = require('./BaseNode');
const Amaz = effect.Amaz;

class CGGetTime extends BaseNode {
  constructor() {
    super();
    this.runtimeCount = 0;
  }

  onUpdate(sys, dt) {
    this.runtimeCount = this.runtimeCount + dt;
    this.outputs[0] = this.runtimeCount;
    this.outputs[1] = dt;
  }

  resetOnRecord(sys){
    this.runtimeCount = 0;
  }
}

exports.CGGetTime = CGGetTime;
