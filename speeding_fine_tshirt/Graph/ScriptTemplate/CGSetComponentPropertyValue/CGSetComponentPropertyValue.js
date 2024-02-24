const Amaz = effect.Amaz;
const {BaseNode} = require('./BaseNode');

class CGSetComponentPropertyValue extends BaseNode {
  constructor() {
    super();
    this.property = null;
    this.resource = null;
    this.propertyFunc = null;
    this.valueType = null;
    this.propertySetingFun = null;
  }

  getPropertyValue() {
    const componentObj = this.inputs[1]();
    if (this.propertyFunc !== null && typeof this.propertyFunc.getProperty === 'function') {
      return this.propertyFunc.getProperty([componentObj], this.property, this.valueType);
    } else {
      return componentObj[this.property];
    }
  }

  beforeStart(sys) {
    this.sys = sys;
  }

  // eslint-disable-next-line complexity
  execute(index) {
    const componentObj = this.inputs[1] ? this.inputs[1]() : null;
    if (componentObj === null || this.property === null || this.inputs[2] === undefined || this.propertyFunc === null) {
      if (this.nexts[0]) {
        this.nexts[0]();
      }
      return false;
    }

    let inputValue = this.inputs[2]();
    if (inputValue === null) {
      if (this.valueType === 'Mesh' || this.valueType === 'Material' || this.valueType === 'Texture2D') {
        inputValue = this.resource;
      }
    }

    // set init value
    if (
      this.sys.setterNodeInitValueMap &&
      !this.sys.setterNodeInitValueMap.has(componentObj.guid.toString() + '|' + this.property)
    ) {
      const initValue = this.propertyFunc.getProperty([componentObj], this.property, this.valueType);
      const callBackFuncMap = new Map();
      callBackFuncMap.set((obj, value) => this.propertyFunc.setProperty([obj], this.property, value, this.valueType), [
        initValue,
      ]);
      this.sys.setterNodeInitValueMap.set(componentObj.guid.toString() + '|' + this.property, callBackFuncMap);
    }

    this.propertyFunc.setProperty([componentObj], this.property, inputValue, this.valueType);
    if (this.propertySetingFun) {
      this.propertySetingFun(componentObj);
    }
    if (this.nexts[0]) {
      this.nexts[0]();
    }
    return true;
  }
}

exports.CGSetComponentPropertyValue = CGSetComponentPropertyValue;
