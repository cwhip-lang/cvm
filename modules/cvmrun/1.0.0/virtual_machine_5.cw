/*
 * modules/cvmrun/1.0.0/virtual_machine_5.cw — Out-of-line VirtualMachine
 * methods, part 5.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Compute decode path for this VirtualMachine. Parameters: instance is an
     * ArrayInstance. It returns String.
     */
    String VirtualMachine.decodePath(ArrayInstance instance) {
        if (instance.elementType() != Value.U8) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "file path array must contain u8 elements")
            return(null)
        }

        int64 cursor = 0
        bool terminated = false
        while (cursor < instance.length() && !terminated && _failure
                == null) {

            int64 first = int64(instance.bytes()[cursor])
            if (first == 0) {
                terminated = true
            }
            else {

                int64 width = 1
                if (first >= 194 && first <= 223) {
                    width = 2
                }
                else {

                    if (first >= 224 && first <= 239) {
                        width = 3
                    }
                    else {

                        if (first >= 240 && first <= 244) {
                            width = 4
                        }
                        else {
                            if (first >= 128) {
                                trap(
                                        ExecutionResult.RUNTIME_TRAP,
                                    "file path is not valid UTF-8")
                                return(null)
                            }
                        }

                    }

                }

                if (width > instance.length() - cursor) {
                    trap(
                            ExecutionResult.RUNTIME_TRAP,
                        "file path is not NUL-terminated valid UTF-8")
                    return(null)
                }

                int64 continuationIndex = 1
                while (continuationIndex < width) {

                    int64 next = (
                            int64(instance.bytes()[cursor
                            + continuationIndex]))
                    bool validContinuation = next >= 128 && next <= 191
                    if (continuationIndex == 1) {
                        if (first == 224 && next < 160) {
                            validContinuation = false
                        }
                        if (first == 237 && next > 159) {
                            validContinuation = false
                        }
                        if (first == 240 && next < 144) {
                            validContinuation = false
                        }
                        if (first == 244 && next > 143) {
                            validContinuation = false
                        }
                    }

                    if (!validContinuation) {
                        trap(
                                ExecutionResult.RUNTIME_TRAP,
                            "file path is not valid UTF-8")
                        return(null)
                    }
                    continuationIndex = continuationIndex + 1
                }

                cursor = cursor + width
            }

        }

        if (_failure != null) {
            return(null)
        }
        if (!terminated) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "file path is not NUL-terminated")
            return(null)
        }
        if (cursor == 0) {
            trap(ExecutionResult.RUNTIME_TRAP, "file path cannot be empty")
            return(null)
        }
        buffer encodedPath = buffer(cursor)
        int64 index = 0
        while (index < cursor) {
            encodedPath[index] = instance.bytes()[index]
            index = index + 1
        }
        try {
            return(Proc.Runtime().textDecode(encodedPath))
        }
        except(Exception) as caught {
            trap(ExecutionResult.RUNTIME_TRAP,
                format(
                    "unable to decode file path as UTF-8: {}",
                    caught.message))
            return(null)
        }
    }

    /*
     * Report whether this VirtualMachine check byte array range. Parameters:
     * instance is an ArrayInstance; offset is an int64; count is an int64;
     * allowZero is a bool; operation is a String. It returns bool.
     */
    bool VirtualMachine.checkByteArrayRange(
            ArrayInstance instance,
            int64 offset,
            int64 count,
                             bool allowZero,
            String operation) {
        if (instance.elementType() != Value.U8) {
            trap(ExecutionResult.RUNTIME_TRAP,
                format(
                    "{} buffer must contain u8 elements",
                    operation))
            return(false)
        }
        if (!allowZero && count == 0) {
            trap(ExecutionResult.RUNTIME_TRAP,
                format(
                    "{} count must be positive",
                    operation))
            return(false)
        }
        if (offset < 0 || count < 0 ||
            offset > instance.length() || count > instance.length()
            - offset) {
            trap(ExecutionResult.RUNTIME_TRAP,
                format(
                    "{} offset/count is outside the byte array",
                    operation))
            return(false)
        }
        return(true)
    }

    /*
     * Compute decode file mode for this VirtualMachine. Parameters: instance
     * is an ArrayInstance. It returns String.
     */
    String VirtualMachine.decodeFileMode(ArrayInstance instance) {
        if (instance.elementType() != Value.U8 || instance.length() < 2) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                "file mode must be a NUL-terminated u8 array containing exactly r, w, or a")
            return(null)
        }
        int64 mode = int64(instance.bytes()[0])
        if (int64(instance.bytes()[1]) != 0 || (
                mode != 114 && mode != 119 && mode != 97)) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                "file mode must be exactly r, w, or a followed by NUL")
            return(null)
        }
        if (mode == 114) {
            return("rb")
        }
        if (mode == 119) {
            return("wb")
        }
        return("ab")
    }

    /*
     * Report whether this VirtualMachine check i o error. Parameters:
     * operation is a String; error is a String. It returns bool.
     */
    bool VirtualMachine.checkIOError(String operation, String error) {
        if (!error.equals("")) {
            trap(ExecutionResult.IO_ERROR, format(
                    "{}: {}",
                    operation,
                    error))
            return(false)
        }
        return(true)
    }

    /*
     * Report whether this VirtualMachine can push service result. It takes no
     * parameters. It returns bool.
     */
    bool VirtualMachine.canPushServiceResult() {
        Frame frame = currentFrame()
        FunctionInfo function = currentFunction()
        if (frame == null || function == null) {
            trap(ExecutionResult.RUNTIME_TRAP, "missing execution frame")
            return(false)
        }
        if (_activeSlots + _stack.length >= _limits.stackValues()) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                "active local and operand value limit exceeded")
            return(false)
        }
        if (_stack.length - frame.stackBase() >= function.maximumStack()) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                "function maximum stack declaration exceeded")
            return(false)
        }
        return(true)
    }
}
