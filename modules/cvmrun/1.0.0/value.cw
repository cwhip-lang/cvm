/*
 * modules/cvmrun/1.0.0/value.cw — Own one operand-stack slot: a scalar, a
 * file handle, or a live array reference.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Own one operand-stack slot: a scalar, a file handle, or a live array
     * reference.
     */
    class Value {
        private:
        int64 _type
        int64 _number
        ArrayInstance _array
        bool _initialized

        public:
        enum {
            I32 = 1, U8 = 2, FILE = 3, ARRAY_REF = 4
        }

        Value(
                int64 valueType,
                int64 number,
                ArrayInstance array,
                bool initialized)

        int64 valueType()

        int64 number()

        ArrayInstance array()

        bool initialized()

    }

    /*
     * Construct a Value and store its initial fields (_type, _number, _array,
     * _initialized). Parameters: valueType is an int64; number is an int64;
     * array is an ArrayInstance; initialized is a bool. It constructs a Value.
     */
    Value Value.Value(
            int64 valueType,
            int64 number,
            ArrayInstance array,
            bool initialized) {
        _type = valueType
        _number = number
        _array = array
        _initialized = initialized
    }

    /*
     * Report value type for this Value. The result is _type. It takes no
     * parameters. It returns int64.
     */
    int64 Value.valueType() {
        return(_type)
    }

    /*
     * Report number for this Value. The result is _number. It takes no
     * parameters. It returns int64.
     */
    int64 Value.number() {
        return(_number)
    }

    /*
     * Report array for this Value. The result is _array. It takes no
     * parameters. It returns ArrayInstance.
     */
    ArrayInstance Value.array() {
        return(_array)
    }

    /*
     * Report initialized for this Value. The result is _initialized. It takes
     * no parameters. It returns bool.
     */
    bool Value.initialized() {
        return(_initialized)
    }
}
