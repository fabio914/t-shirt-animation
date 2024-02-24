'use strict';
const Amaz = effect.Amaz;
const {BaseNode} = require('./BaseNode');
class CGSetMaterial extends BaseNode {
  constructor() {
    super();
    this.materialPropertySheetNameMap = {
      Texture2D: 'texmap',
      Double: 'floatmap',
      Vector2f: 'vec2map',
      Vector3f: 'vec3map',
      Vector4f: 'vec4map',
      Color: 'vec4map',
      Matrix4x4f: 'mat4map',
    };
    this.materialSetterMap = {
      Texture2D: 'setTex',
      Double: 'setFloat',
      Vector2f: 'setVec2',
      Vector3f: 'setVec3',
      Vector4f: 'setVec4',
      Color: 'setVec4',
      Matrix4x4f: 'setMat4',
    };
    this.materialGetterMap = {
      Texture2D: 'getTex',
      Double: 'getFloat',
      Vector2f: 'getVec2',
      Vector3f: 'getVec3',
      Vector4f: 'getVec4',
      Color: 'getVec4',
      Matrix4x4f: 'getMat4',
    };
  }

  beforeStart(sys) {
    this.sys = sys;
  }

  transValueType(value) {
    if (this.valueType === 'Color' && value instanceof Amaz.Color) {
      return new Amaz.Vector4f(value.r, value.g, value.b, value.a);
    } else {
      return value;
    }
  }

  execute() {
    const materialArray = this.inputs[1]();
    const uniformName = this.inputs[2]();
    const uniformValue = this.inputs[3]();

    if (
      materialArray === null ||
      materialArray === undefined ||
      uniformName === null ||
      uniformName === undefined ||
      uniformValue === null ||
      uniformValue === undefined
    ) {
      return;
    }

    const materialUniform = this.transValueType(uniformValue);

    for (const material of materialArray) {
      if (material === null || material === undefined) {
        return;
      }

      const propertySheetHasIntUniform = material.properties.intmap.has(uniformName);

      if (
        this.sys.setterNodeInitValueMap &&
        !this.sys.setterNodeInitValueMap.has(material.guid.toString() + '|' + uniformName)
      ) {
        const callBackFuncMap = new Map();
        if (propertySheetHasIntUniform) {
          callBackFuncMap.set(
            (_material, _intUniformName, _intUniformValue) => _material.setInt(_intUniformName, _intUniformValue),
            [uniformName, material.getInt(uniformName)]
          );
        } else {
          const propertySheet = material.properties[this.materialPropertySheetNameMap[this.valueType]];
          if (propertySheet.has(uniformName)) {
            callBackFuncMap.set(
              (_material, _uniformName, _uniformValue) =>
                _material[this.materialSetterMap[this.valueType]](_uniformName, _uniformValue),
              [uniformName, material[this.materialGetterMap[this.valueType]](uniformName)]
            );
          }
        }
        this.sys.setterNodeInitValueMap.set(material.guid.toString() + '|' + uniformName, callBackFuncMap);
      }

      // Handling the int edge case
      if (propertySheetHasIntUniform) {
        material.setInt(uniformName, Math.round(materialUniform));
      } else {
        const propertySheet = material.properties[this.materialPropertySheetNameMap[this.valueType]];

        if (propertySheet.has(uniformName)) {
          material[this.materialSetterMap[this.valueType]](uniformName, materialUniform);
        }
      }
    }

    if (this.nexts[0]) {
      this.nexts[0]();
    }
  }
}
exports.CGSetMaterial = CGSetMaterial;
