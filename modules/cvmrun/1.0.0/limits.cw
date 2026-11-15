/*
 * modules/cvmrun/1.0.0/limits.cw — Own the execution budgets for program
 * size, instructions, stack, calls, and heap.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Own the execution budgets for program size, instructions, stack, calls,
     * and heap.
     */
    class Limits {
        private:
        int64 _programBytes
        int64 _instructions
        int64 _stackValues
        int64 _callDepth
        int64 _heapBytes

        public:
        enum {
            DEFAULT_PROGRAM_BYTES = 16777216,
            DEFAULT_INSTRUCTIONS = 1000000,
            DEFAULT_STACK_VALUES = 65536,
            DEFAULT_CALL_DEPTH = 256,
            DEFAULT_HEAP_BYTES = 16777216,
            ARRAY_INSTANCE_OVERHEAD = 256,
            MAX_PROGRAM_BYTES = 67108864,
            MAX_INSTRUCTIONS = 100000000,
            MAX_STACK_VALUES = 1048576,
            MAX_CALL_DEPTH = 4096,
            MAX_HEAP_BYTES = 268435456
        }

        Limits()

        Limits(
                int64 programBytes,
                int64 instructions,
                int64 stackValues,
                int64 callDepth,
                int64 heapBytes)

        bool valid()

        int64 programBytes()

        int64 instructions()

        int64 stackValues()

        int64 callDepth()

        int64 heapBytes()

    }

    /*
     * Construct a Limits and store its initial fields (_programBytes,
     * _instructions, _stackValues, _callDepth, _heapBytes). It takes no
     * parameters. It constructs a Limits.
     */
    Limits Limits.Limits() {
        _programBytes = DEFAULT_PROGRAM_BYTES
        _instructions = DEFAULT_INSTRUCTIONS
        _stackValues = DEFAULT_STACK_VALUES
        _callDepth = DEFAULT_CALL_DEPTH
        _heapBytes = DEFAULT_HEAP_BYTES
    }

    /*
     * Construct a Limits and store its initial fields (_programBytes,
     * _instructions, _stackValues, _callDepth, _heapBytes). Parameters:
     * programBytes is an int64; instructions is an int64; stackValues is an
     * int64; callDepth is an int64; heapBytes is an int64. It constructs a
     * Limits.
     */
    Limits Limits.Limits(
            int64 programBytes,
            int64 instructions,
            int64 stackValues,
            int64 callDepth,
            int64 heapBytes) {
        _programBytes = programBytes
        _instructions = instructions
        _stackValues = stackValues
        _callDepth = callDepth
        _heapBytes = heapBytes
    }

    /*
     * Report whether this Limits valid. It takes no parameters. It returns
     * bool.
     */
    bool Limits.valid() {
        return(
                _programBytes > 0 && _programBytes <= MAX_PROGRAM_BYTES
                && _instructions > 0 && _instructions <= MAX_INSTRUCTIONS
                && _stackValues > 0 && _stackValues <= MAX_STACK_VALUES
                && _callDepth > 0 && _callDepth <= MAX_CALL_DEPTH
                && _heapBytes >= 0 && _heapBytes <= MAX_HEAP_BYTES)
    }

    /*
     * Report program bytes for this Limits. The result is _programBytes. It
     * takes no parameters. It returns int64.
     */
    int64 Limits.programBytes() {
        return(_programBytes)
    }

    /*
     * Report instructions for this Limits. The result is _instructions. It
     * takes no parameters. It returns int64.
     */
    int64 Limits.instructions() {
        return(_instructions)
    }

    /*
     * Report stack values for this Limits. The result is _stackValues. It
     * takes no parameters. It returns int64.
     */
    int64 Limits.stackValues() {
        return(_stackValues)
    }

    /*
     * Report call depth for this Limits. The result is _callDepth. It takes no
     * parameters. It returns int64.
     */
    int64 Limits.callDepth() {
        return(_callDepth)
    }

    /*
     * Report heap bytes for this Limits. The result is _heapBytes. It takes no
     * parameters. It returns int64.
     */
    int64 Limits.heapBytes() {
        return(_heapBytes)
    }
}
