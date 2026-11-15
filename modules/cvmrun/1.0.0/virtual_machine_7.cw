/*
 * modules/cvmrun/1.0.0/virtual_machine_7.cw — Out-of-line VirtualMachine
 * methods, part 7.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Perform free frame on this VirtualMachine. Parameters: frame is a Frame.
     * It does not return a value.
     */
    void VirtualMachine.freeFrame(Frame frame) {
        list arrays = frame.localArrays()
        int64 index = 0
        while (index < arrays.length) {
            ArrayInstance instance = arrays[index] as ArrayInstance
            if (instance != null && instance.alive()) {
                instance.kill()
                _heapBytes = _heapBytes - instance.heapBytes()
            }
            index = index + 1
        }
        _activeSlots = _activeSlots - frame.locals().length
        frame.kill()
    }

    /*
     * Report whether this VirtualMachine do return. Parameters: returnType is
     * an int64. It returns bool.
     */
    bool VirtualMachine.doReturn(int64 returnType) {
        Frame frame = currentFrame()
        FunctionInfo function = currentFunction()
        if (function.returnType() != returnType) {
            trap(ExecutionResult.RUNTIME_TRAP,
                format(
                        "return type mismatch: function declares {}, instruction returns {}",
                    typeName(function.returnType()), typeName(
                    returnType)))
            return(false)
        }
        int64 expectedValues = 0
        if (returnType != 0) {
            expectedValues = 1
        }
        if (_stack.length != frame.stackBase() + expectedValues) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "return has extra or missing operand stack values")
            return(false)
        }
        Value returned = null
        if (expectedValues == 1) {
            returned = popType(returnType)
            if (returned == null || _failure != null) {
                return(false)
            }
        }
        int64 functionIndex = frame.functionIndex()
        int64 callerOffset = frame.callOffset()
        freeFrame(frame)
        _frames.resize(_frames.length - 1)

        if (_frames.length == 0) {
            if (functionIndex != _entry || returnType != Value.I32
                    || returned == null) {
                failAt(
                        ExecutionResult.RUNTIME_TRAP,
                        "invalid entry return",
                        functionIndex,
                        _activeOffset)
                return(false)
            }
            _guestResult = returned.number()
            _completed = true
            return(true)
        }

        if (returned != null) {
            _activeOffset = callerOffset
            if (!push(returned)) {
                return(false)
            }
        }
        return(true)
    }

    /*
     * Report whether this VirtualMachine compare values. Parameters: opcode is
     * an int64. It returns bool.
     */
    bool VirtualMachine.compareValues(int64 opcode) {
        Value right = popType(Value.I32)
        if (right == null || _failure != null) {
            return(false)
        }
        Value left = popType(Value.I32)
        if (left == null || _failure != null) {
            return(false)
        }
        bool result = false
        if (opcode == CVM.Opcode.EQ_I32) {
            result = left.number() == right.number()
        }
        if (opcode == CVM.Opcode.NE_I32) {
            result = left.number() != right.number()
        }
        if (opcode == CVM.Opcode.LT_I32) {
            result = left.number() < right.number()
        }
        if (opcode == CVM.Opcode.LE_I32) {
            result = left.number() <= right.number()
        }
        if (opcode == CVM.Opcode.GT_I32) {
            result = left.number() > right.number()
        }
        if (opcode == CVM.Opcode.GE_I32) {
            result = left.number() >= right.number()
        }
        int64 number = 0
        if (result) {
            number = 1
        }
        return(push(Value(Value.I32, number, null, true)))
    }

    /*
     * Report whether this VirtualMachine binary i32. Parameters: opcode is an
     * int64. It returns bool.
     */
    bool VirtualMachine.binaryI32(int64 opcode) {
        Value right = popType(Value.I32)
        if (right == null || _failure != null) {
            return(false)
        }
        Value left = popType(Value.I32)
        if (left == null || _failure != null) {
            return(false)
        }
        int64 a = left.number()
        int64 b = right.number()
        int64 result = 0
        if (opcode == CVM.Opcode.ADD_I32) {
            result = a + b
        }
        if (opcode == CVM.Opcode.SUB_I32) {
            result = a - b
        }
        if (opcode == CVM.Opcode.MUL_I32) {
            result = a * b
        }

        if (opcode == CVM.Opcode.DIV_I32 || opcode == CVM.Opcode.REM_I32) {
            if (b == 0) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "integer division by zero")
                return(false)
            }
            if (a == -2147483648 && b == -1) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "i32 division or remainder overflow")
                return(false)
            }
            if (opcode == CVM.Opcode.DIV_I32) {
                result = a / b
            }
            else {
                result = a % b
            }
        }

        if (result < -2147483648 || result > 2147483647) {
            trap(ExecutionResult.RUNTIME_TRAP, "i32 arithmetic overflow")
            return(false)
        }
        return(push(Value(Value.I32, result, null, true)))
    }
}
