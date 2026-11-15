/*
 * modules/cvm/1.0.0/instruction_builder.cw — Emit v1 instructions with the
 * canonical operand width. The first error sticks.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Emit v1 instructions with the canonical operand width. The first error
     * sticks.
     */
    class InstructionBuilder {
        private:
        buffer _code
        int64 _error
        String _message

        bool appendAll(buffer source)

        bool fail(int64 code, String message)

        public:
        enum {
            OK = 0, INVALID_VALUE = 1, INVALID_INSTRUCTION = 2
        }

        InstructionBuilder()

        bool emit(int64 opcode, int64 operand)

        bool emitNoOperand(int64 opcode)

        buffer bytes()

        int64 errorCode()

        String errorMessage()

    }

    /*
     * Report whether this InstructionBuilder append all. Parameters: source is
     * a buffer. It returns bool.
     */
    bool InstructionBuilder.appendAll(buffer source) {
        int64 index = 0
        while (index < source.length) {
            _code.append(source[index])
            index = index + 1
        }
        return(true)
    }

    /*
     * Report whether this InstructionBuilder fail. Parameters: code is an
     * int64; message is a String. It returns bool.
     */
    bool InstructionBuilder.fail(int64 code, String message) {
        if (_error == 0) {
            _error = code
            _message = message
        }
        return(false)
    }

    /*
     * Construct an InstructionBuilder and store its initial fields (_code,
     * _error, _message). It takes no parameters. It constructs an
     * InstructionBuilder.
     */
    InstructionBuilder InstructionBuilder.InstructionBuilder() {
        _code = buffer[]
        _error = 0
        _message = ""
    }

    /*
     * Report whether this InstructionBuilder emit. Parameters: opcode is an
     * int64; operand is an int64. It returns bool.
     */
    bool InstructionBuilder.emit(int64 opcode, int64 operand) {
        if (_error != 0) {
            return(false)
        }
        Opcode schema = Opcode()
        if (!schema.isValid(opcode)) {
            return(fail(INVALID_INSTRUCTION, "unknown opcode"))
        }
        int64 width = schema.operandWidth(opcode)
        int64 kind = schema.operandKind(opcode)
        if (width == 0) {
            return(fail(INVALID_INSTRUCTION, "opcode has no operand"))
        }
        if (kind == 1 && (operand < -2147483648 || operand > 2147483647)) {
            return(fail(INVALID_VALUE, "i32 operand out of range"))
        }
        if (kind == 2 && (operand < 0 || operand > 255 || (
                opcode == Opcode.SYS && operand
                > Service.FILE_CLOSE_HANDLE))) {
            return(fail(INVALID_VALUE, "u8 operand out of range"))
        }
        if ((kind == 3 || kind == 4 || kind == 5 || kind == 7) && (
                operand < 0 || operand > 65535)) {
            return(fail(INVALID_VALUE, "u16 operand out of range"))
        }
        if (kind == 6 && (operand < 0 || operand > 4294967295)) {
            return(fail(INVALID_VALUE, "branch target out of range"))
        }
        _code.append(opcode)

        if (width == 1) {
            _code.append(operand)
        }
        else {

            if (width == 2) {
                _code.append(operand % 256)
                _code.append((operand / 256) % 256)
            }
            else {
                ByteWriter writer = ByteWriter()
                if (kind == 1) {
                    writer.writeI32(operand)
                }
                else {
                    writer.writeU32(uint64(operand))
                }
                appendAll(writer.bytes())
            }

        }

        return(true)
    }

    /*
     * Report whether this InstructionBuilder emit no operand. Parameters:
     * opcode is an int64. It returns bool.
     */
    bool InstructionBuilder.emitNoOperand(int64 opcode) {
        if (_error != 0) {
            return(false)
        }
        Opcode schema = Opcode()
        if (!schema.isValid(opcode) || schema.operandWidth(opcode) != 0) {
            return(fail(INVALID_INSTRUCTION, "invalid no-operand opcode"))
        }
        _code.append(opcode)
        return(true)
    }

    /*
     * Report bytes for this InstructionBuilder. The result is _code. It takes
     * no parameters. It returns buffer.
     */
    buffer InstructionBuilder.bytes() {
        return(_code)
    }

    /*
     * Report error code for this InstructionBuilder. The result is _error. It
     * takes no parameters. It returns int64.
     */
    int64 InstructionBuilder.errorCode() {
        return(_error)
    }

    /*
     * Report error message for this InstructionBuilder. The result is
     * _message. It takes no parameters. It returns String.
     */
    String InstructionBuilder.errorMessage() {
        return(_message)
    }
}
