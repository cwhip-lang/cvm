/*
 * modules/cvmrun/1.0.0/frame.cw — Own one call frame: function, program
 * counter, stack base, and the arrays it created.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Own one call frame: function, program counter, stack base, and the
     * arrays it created.
     */
    class Frame {
        private:
        int64 _functionIndex
        int64 _pc
        int64 _stackBase
        int64 _callOffset
        list _locals
        list _localArrays
        bool _active

        public:
        Frame(
                int64 functionIndex,
                int64 pc,
                int64 stackBase,
                int64 callOffset,
                list locals)

        int64 functionIndex()

        int64 pc()

        void setPc(int64 pc)

        int64 stackBase()

        int64 callOffset()

        list locals()

        list localArrays()

        bool active()

        void addArray(ArrayInstance array)

        void kill()

    }

    /*
     * Construct a Frame and store its initial fields (_functionIndex, _pc,
     * _stackBase, _callOffset, _locals, _localArrays, _active). Parameters:
     * functionIndex is an int64; pc is an int64; stackBase is an int64;
     * callOffset is an int64; locals is a list. It constructs a Frame.
     */
    Frame Frame.Frame(
            int64 functionIndex,
            int64 pc,
            int64 stackBase,
            int64 callOffset,
            list locals) {
        _functionIndex = functionIndex
        _pc = pc
        _stackBase = stackBase
        _callOffset = callOffset
        _locals = locals
        _localArrays = []
        _active = true
    }

    /*
     * Report function index for this Frame. The result is _functionIndex. It
     * takes no parameters. It returns int64.
     */
    int64 Frame.functionIndex() {
        return(_functionIndex)
    }

    /*
     * Report pc for this Frame. The result is _pc. It takes no parameters. It
     * returns int64.
     */
    int64 Frame.pc() {
        return(_pc)
    }

    /*
     * Perform set pc on this Frame. Parameters: pc is an int64. It does not
     * return a value.
     */
    void Frame.setPc(int64 pc) {
        _pc = pc
    }

    /*
     * Report stack base for this Frame. The result is _stackBase. It takes no
     * parameters. It returns int64.
     */
    int64 Frame.stackBase() {
        return(_stackBase)
    }

    /*
     * Report call offset for this Frame. The result is _callOffset. It takes
     * no parameters. It returns int64.
     */
    int64 Frame.callOffset() {
        return(_callOffset)
    }

    /*
     * Report locals for this Frame. The result is _locals. It takes no
     * parameters. It returns list.
     */
    list Frame.locals() {
        return(_locals)
    }

    /*
     * Report local arrays for this Frame. The result is _localArrays. It takes
     * no parameters. It returns list.
     */
    list Frame.localArrays() {
        return(_localArrays)
    }

    /*
     * Report active for this Frame. The result is _active. It takes no
     * parameters. It returns bool.
     */
    bool Frame.active() {
        return(_active)
    }

    /*
     * Perform add array on this Frame. Parameters: array is an ArrayInstance.
     * It does not return a value.
     */
    void Frame.addArray(ArrayInstance array) {
        _localArrays.append(array)
    }

    /*
     * Perform kill on this Frame. It takes no parameters. It does not return a
     * value.
     */
    void Frame.kill() {
        _active = false
    }
}
