template `=~`*[T: float32|Vector2|Vector3|Vector4|Quaternion](v1, v2: T): bool = equals(v1, v2)

template `+`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1, v2: T): T = add(v1, v2)
template `+=`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1: var T, v2: T) = v1 = add(v1, v2)
template `+`*[T: Vector2|Vector3|Vector4|Quaternion](v1: T, value: float32): T = addValue(v1, value)
template `+=`*[T: Vector2|Vector3|Vector4|Quaternion](v1: var T, value: float32) = v1 = addValue(v1, value)

template `-`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1, v2: T): T = subtract(v1, v2)
template `-=`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1: var T, v2: T) = v1 = subtract(v1, v2)
template `-`*[T: Vector2|Vector3|Vector4|Quaternion](v1: T, value: float32): T = subtractValue(v1, value)
template `-=`*[T: Vector2|Vector3|Vector4|Quaternion](v1: var T, value: float32) = v1 = subtractValue(v1, value)

template `*`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1, v2: T): T = multiply(v1, v2)
template `*=`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1: var T, v2: T) = v1 = multiply(v1, v2)
template `*`*[T: Vector2|Vector3|Vector4|Quaternion](v1: T, value: float32): T = scale(v1, value)
template `*=`*[T: Vector2|Vector3|Vector4|Quaternion](v1: var T, value: float32) = v1 = scale(v1, value)

template `/`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1, v2: T): T = divide(v1, v2)
template `/=`*[T: Vector2|Vector3|Vector4|Quaternion|Matrix](v1: var T, v2: T) = v1 = divide(v1, v2)
template `/`*[T: Vector2|Vector3|Vector4|Quaternion](v1: T, value: float32): T = scale(v1, 1'f32/value)
template `/=`*[T: Vector2|Vector3|Vector4|Quaternion](v1: var T, value: float32) = v1 = scale(v1, 1'f32/value)

template `-`*[T: Vector2|Vector3|Vector4](v1: T): T = negate(v1)
