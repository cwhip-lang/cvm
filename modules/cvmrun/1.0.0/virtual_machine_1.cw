/*
 * modules/cvmrun/1.0.0/virtual_machine_1.cw — Out-of-line VirtualMachine
 * methods, part 1.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Perform reset on this VirtualMachine. Parameters: limits is a Limits. It
     * does not return a value.
     */
    void VirtualMachine.reset(Limits limits) {
        _functions = []
        _globals = []
        _arrayInfos = []
        _globalArrays = []
        _frames = []
        _stack = []
        _code = buffer[]
        _types = buffer[]
        _data = buffer[]
        _limits = limits
        _capabilities = Capabilities()
        _failure = null
        _fileHandles = []
        _stdinFile = null
        _stdinOpen = false
        if (_nextFileHandle <= 0) {
            _nextFileHandle = 1
        }
        _entry = -1
        _steps = 0
        _heapBytes = 0
        _activeSlots = 0
        _activeOffset = 0
        _guestResult = 0
        _completed = false
    }

    /*
     * Compute byte at for this VirtualMachine. Parameters: bytes is a buffer;
     * offset is an int64; section is an int64. It returns int64.
     */
    int64 VirtualMachine.byteAt(buffer bytes, int64 offset, int64 section) {
        if (bytes == null || offset < 0 || offset >= bytes.length) {
            loadFailure(section, offset, "truncated section data")
            return(0)
        }
        return(int64(bytes[offset]))
    }

    /*
     * Compute u16 at for this VirtualMachine. Parameters: bytes is a buffer;
     * offset is an int64; section is an int64. It returns int64.
     */
    int64 VirtualMachine.u16At(buffer bytes, int64 offset, int64 section) {
        if (bytes == null || offset < 0 || offset > bytes.length
                || bytes.length - offset < 2) {
            loadFailure(section, offset, "truncated 16-bit field")
            return(0)
        }
        return(int64(bytes[offset]) + int64(bytes[offset + 1]) * 256)
    }

    /*
     * Compute u32 at for this VirtualMachine. Parameters: bytes is a buffer;
     * offset is an int64; section is an int64. It returns int64.
     */
    int64 VirtualMachine.u32At(buffer bytes, int64 offset, int64 section) {
        if (bytes == null || offset < 0 || offset > bytes.length
                || bytes.length - offset < 4) {
            loadFailure(section, offset, "truncated 32-bit field")
            return(0)
        }
        return(int64(bytes[offset]) + int64(bytes[offset + 1]) * 256
                + int64(bytes[
                offset + 2]) * 65536 + int64(bytes[
                offset + 3]) * 16777216)
    }

    /*
     * Compute i32 at for this VirtualMachine. Parameters: bytes is a buffer;
     * offset is an int64; section is an int64. It returns int64.
     */
    int64 VirtualMachine.i32At(buffer bytes, int64 offset, int64 section) {
        int64 value = u32At(bytes, offset, section)
        if (_failure != null) {
            return(0)
        }
        if (value >= 2147483648) {
            return(value - 4294967296)
        }
        return(value)
    }

    /*
     * Perform load failure on this VirtualMachine. Parameters: section is an
     * int64; offset is an int64; message is a String. It does not return a
     * value.
     */
    void VirtualMachine.loadFailure(int64 section, int64 offset,
            String message)
    {
        if (_failure == null) {
            _failure = ExecutionResult(ExecutionResult.LOAD_ERROR, 0,
                    message,
                section, offset, -1, "", -1, _steps)
        }
    }

    /*
     * Perform validation failure on this VirtualMachine. Parameters:
     * validation is a CVM.ValidationResult. It does not return a value.
     */
    void VirtualMachine.validationFailure(CVM.ValidationResult validation) {
        _failure = ExecutionResult(ExecutionResult.VALIDATION_ERROR, 0,
            validation.message(), validation.section(),
            validation.offset(),
            -1, "", -1, _steps)
    }

    /*
     * Perform fail at on this VirtualMachine. Parameters: category is an
     * int64; message is a String; functionIndex is an int64; offset is an
     * int64. It does not return a value.
     */
    void VirtualMachine.failAt(
            int64 category,
            String message,
            int64 functionIndex,
            int64 offset) {
        if (_failure != null) {
            return
        }
        String name = ""
        if (functionIndex >= 0 && functionIndex < _functions.length) {
            FunctionInfo function = (
                    _functions[functionIndex] as FunctionInfo)
            name = function.name()
        }
        _failure = ExecutionResult(category, 0, message, 0, -1,
            functionIndex, name, offset, _steps)
    }

    /*
     * Perform trap on this VirtualMachine. Parameters: category is an int64;
     * message is a String. It does not return a value.
     */
    void VirtualMachine.trap(int64 category, String message) {
        Frame frame = null
        int64 functionIndex = -1
        int64 offset = _activeOffset
        if (_frames.length > 0) {
            frame = _frames[_frames.length - 1] as Frame
            functionIndex = frame.functionIndex()
        }
        failAt(category, message, functionIndex, offset)
    }

    /*
     * Compute name at for this VirtualMachine. Parameters: strings is a
     * buffer; offset is an int64. It returns String.
     */
    String VirtualMachine.nameAt(buffer strings, int64 offset) {
        if (offset < 0 || offset >= strings.length) {
            loadFailure(
                    CVM.Format.STRINGS,
                    offset,
                    "function name offset is outside STRINGS")
            return("")
        }

        String name = ""
        int64 cursor = offset
        bool terminated = false
        while (cursor < strings.length && !terminated) {

            int64 byte = int64(strings[cursor])
            if (byte == 0) {
                terminated = true
            }
            else {
                if (byte >= 128) {
                    loadFailure(
                            CVM.Format.STRINGS,
                            cursor,
                            "function name is not ASCII")
                    return("")
                }
                name.append(format("{:c}", byte))
                cursor = cursor + 1
            }

        }

        if (!terminated) {
            loadFailure(
                    CVM.Format.STRINGS,
                    offset,
                    "unterminated function name")
        }
        return(name)
    }
}
