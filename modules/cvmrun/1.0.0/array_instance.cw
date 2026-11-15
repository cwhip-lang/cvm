/*
 * modules/cvmrun/1.0.0/array_instance.cw — Own the heap bytes of one array
 * created for a run. kill marks those bytes dead.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Own the heap bytes of one array created for a run. kill marks those
     * bytes dead.
     */
    class ArrayInstance {
        private:
        int64 _index
        int64 _elementType
        int64 _length
        buffer _bytes
        bool _alive
        int64 _heapBytes

        public:
        ArrayInstance(
                int64 index,
                int64 elementType,
                int64 length,
                buffer bytes,
                int64 heapBytes)

        int64 index()

        int64 elementType()

        int64 length()

        buffer bytes()

        bool alive()

        int64 heapBytes()

        void kill()

    }

    /*
     * Construct an ArrayInstance and store its initial fields (_index,
     * _elementType, _length, _bytes, _alive, _heapBytes). Parameters: index is
     * an int64; elementType is an int64; length is an int64; bytes is a
     * buffer; heapBytes is an int64. It constructs an ArrayInstance.
     */
    ArrayInstance ArrayInstance.ArrayInstance(
            int64 index,
            int64 elementType,
            int64 length,
            buffer bytes,
            int64 heapBytes) {
        _index = index
        _elementType = elementType
        _length = length
        _bytes = bytes
        _alive = true
        _heapBytes = heapBytes
    }

    /*
     * Report index for this ArrayInstance. The result is _index. It takes no
     * parameters. It returns int64.
     */
    int64 ArrayInstance.index() {
        return(_index)
    }

    /*
     * Report element type for this ArrayInstance. The result is _elementType.
     * It takes no parameters. It returns int64.
     */
    int64 ArrayInstance.elementType() {
        return(_elementType)
    }

    /*
     * Report length for this ArrayInstance. The result is _length. It takes no
     * parameters. It returns int64.
     */
    int64 ArrayInstance.length() {
        return(_length)
    }

    /*
     * Report bytes for this ArrayInstance. The result is _bytes. It takes no
     * parameters. It returns buffer.
     */
    buffer ArrayInstance.bytes() {
        return(_bytes)
    }

    /*
     * Report alive for this ArrayInstance. The result is _alive. It takes no
     * parameters. It returns bool.
     */
    bool ArrayInstance.alive() {
        return(_alive)
    }

    /*
     * Report heap bytes for this ArrayInstance. The result is _heapBytes. It
     * takes no parameters. It returns int64.
     */
    int64 ArrayInstance.heapBytes() {
        return(_heapBytes)
    }

    /*
     * Perform kill on this ArrayInstance. It takes no parameters. It does not
     * return a value.
     */
    void ArrayInstance.kill() {
        _alive = false
    }
}
