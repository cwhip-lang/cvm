/*
 * modules/cvmrun/1.0.0/array_info.cw — Own the declaration of one global or
 * function-local array.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Own the declaration of one global or function-local array.
     */
    class ArrayInfo {
        private:
        int64 _owner
        int64 _elementType
        int64 _length
        bool _initialized
        int64 _dataOffset

        public:
        ArrayInfo(
                int64 owner,
                int64 elementType,
                int64 length,
                bool initialized,
                int64 dataOffset)

        int64 owner()

        int64 elementType()

        int64 length()

        bool initialized()

        int64 dataOffset()

    }

    /*
     * Construct an ArrayInfo and store its initial fields (_owner,
     * _elementType, _length, _initialized, _dataOffset). Parameters: owner is
     * an int64; elementType is an int64; length is an int64; initialized is a
     * bool; dataOffset is an int64. It constructs an ArrayInfo.
     */
    ArrayInfo ArrayInfo.ArrayInfo(
            int64 owner,
            int64 elementType,
            int64 length,
            bool initialized,
            int64 dataOffset) {
        _owner = owner
        _elementType = elementType
        _length = length
        _initialized = initialized
        _dataOffset = dataOffset
    }

    /*
     * Report owner for this ArrayInfo. The result is _owner. It takes no
     * parameters. It returns int64.
     */
    int64 ArrayInfo.owner() {
        return(_owner)
    }

    /*
     * Report element type for this ArrayInfo. The result is _elementType. It
     * takes no parameters. It returns int64.
     */
    int64 ArrayInfo.elementType() {
        return(_elementType)
    }

    /*
     * Report length for this ArrayInfo. The result is _length. It takes no
     * parameters. It returns int64.
     */
    int64 ArrayInfo.length() {
        return(_length)
    }

    /*
     * Report initialized for this ArrayInfo. The result is _initialized. It
     * takes no parameters. It returns bool.
     */
    bool ArrayInfo.initialized() {
        return(_initialized)
    }

    /*
     * Report data offset for this ArrayInfo. The result is _dataOffset. It
     * takes no parameters. It returns int64.
     */
    int64 ArrayInfo.dataOffset() {
        return(_dataOffset)
    }
}
