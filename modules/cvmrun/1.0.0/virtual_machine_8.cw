/*
 * modules/cvmrun/1.0.0/virtual_machine_8.cw — Out-of-line VirtualMachine
 * methods, part 8.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Report whether this VirtualMachine execute one. It takes no parameters.
     * It returns bool.
     */
    bool VirtualMachine.executeOne() {
        Frame frame = currentFrame()
        if (frame == null) {
            trap(ExecutionResult.RUNTIME_TRAP, "missing execution frame")
            return(false)
        }
        FunctionInfo function = currentFunction()
        if (frame.pc() < 0 || frame.pc() >= function.codeLength()) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "reachable function fallthrough")
            return(false)
        }
        _activeOffset = frame.pc()
        if (_steps >= _limits.instructions()) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                    "instruction limit exceeded")
            return(false)
        }
        _steps = _steps + 1
        int64 opcode = readCodeByte(frame, function, frame.pc())
        if (_failure != null) {
            return(false)
        }
        frame.setPc(frame.pc() + 1)

        if (opcode == CVM.Opcode.NOP) {
            return(true)
        }
        if (opcode == CVM.Opcode.CONST_I32) {
            int64 value = readOperand(frame, function, 4)
            if (_failure != null) {
                return(false)
            }
            if (value >= 2147483648) {
                value = value - 4294967296
            }
            return(push(Value(Value.I32, value, null, true)))
        }
        if (opcode == CVM.Opcode.CONST_U8) {
            int64 value = readOperand(frame, function, 1)
            if (_failure != null) {
                return(false)
            }
            return(push(Value(Value.U8, value, null, true)))
        }

        if (opcode == CVM.Opcode.LDLOC || opcode == CVM.Opcode.STLOC) {
            int64 index = readOperand(frame, function, 2)
            if (_failure != null) {
                return(false)
            }
            list locals = frame.locals()
            if (index < 0 || index >= locals.length) {
                trap(ExecutionResult.RUNTIME_TRAP,
                        "local index is invalid")
                return(false)
            }
            if (opcode == CVM.Opcode.LDLOC) {
                Value value = locals[index] as Value
                if (value == null || !value.initialized()) {
                    trap(ExecutionResult.RUNTIME_TRAP, format(
                            "local {} is uninitialized",
                            index))
                    return(false)
                }
                return(push(value))
            }
            Value stored = popAny()
            if (stored == null || _failure != null) {
                return(false)
            }
            if (stored.valueType() != localType(function, index)) {
                trap(ExecutionResult.RUNTIME_TRAP, format(
                        "local {} store type mismatch",
                        index))
                return(false)
            }
            locals[index] = stored
            return(push(stored))
        }

        if (opcode == CVM.Opcode.LDGLOBAL || opcode
                == CVM.Opcode.STGLOBAL) {
            int64 index = readOperand(frame, function, 2)
            if (_failure != null) {
                return(false)
            }
            if (index < 0 || index >= _globals.length) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "global index is invalid")
                return(false)
            }
            if (opcode == CVM.Opcode.LDGLOBAL) {
                return(push(_globals[index] as Value))
            }
            Value stored = popAny()
            if (stored == null || _failure != null) {
                return(false)
            }
            Value existing = _globals[index] as Value
            if (stored.valueType() != existing.valueType()) {
                trap(ExecutionResult.RUNTIME_TRAP, format(
                        "global {} store type mismatch",
                        index))
                return(false)
            }
            _globals[index] = stored
            return(push(stored))
        }

        if (opcode == CVM.Opcode.ARRAY) {
            int64 index = readOperand(frame, function, 2)
            if (_failure != null) {
                return(false)
            }
            ArrayInstance instance = arrayFor(frame, index)
            if (instance == null || _failure != null) {
                return(false)
            }
            return(push(Value(Value.ARRAY_REF, 0, instance, true)))
        }

        if (opcode == CVM.Opcode.ALEN) {
            Value reference = popType(Value.ARRAY_REF)
            if (reference == null || _failure != null
                    || !validArrayReference(
                    reference)) {
                return(false)
            }
            return(push(Value(
                    Value.I32,
                    reference.array().length(),
                    null,
                    true)))
        }

        if (opcode == CVM.Opcode.AGET || opcode == CVM.Opcode.ASET) {
            Value stored = null
            if (opcode == CVM.Opcode.ASET) {
                stored = popAny()
                if (stored == null || _failure != null) {
                    return(false)
                }
            }
            Value indexValue = popType(Value.I32)
            if (indexValue == null || _failure != null) {
                return(false)
            }
            Value reference = popType(Value.ARRAY_REF)
            if (reference == null || _failure != null
                    || !validArrayReference(
                    reference)) {
                return(false)
            }
            ArrayInstance instance = reference.array()
            int64 index = indexValue.number()
            if (index < 0 || index >= instance.length()) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "array index is out of bounds")
                return(false)
            }

            if (opcode == CVM.Opcode.AGET) {
                int64 value = 0
                if (instance.elementType() == Value.U8) {
                    value = int64(instance.bytes()[index])
                }
                else {
                    int64 at = index * 4
                    value = (
                            int64(instance.bytes()[at])
                            + int64(instance.bytes()[at + 1]) * 256
                            + int64(instance.bytes()[at + 2]) * 65536
                            + int64(instance.bytes()[at + 3]) * 16777216)
                    if (value >= 2147483648) {
                        value = value - 4294967296
                    }
                }
                return(push(
                        Value(instance.elementType(), value, null, true)))
            }

            if (stored.valueType() != instance.elementType()) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "array store type mismatch")
                return(false)
            }

            if (instance.elementType() == Value.U8) {
                instance.bytes()[index] = uint8(stored.number())
            }
            else {
                int64 value = stored.number()
                if (value < 0) {
                    value = value + 4294967296
                }
                int64 at = index * 4
                instance.bytes()[at] = uint8(value % 256)
                instance.bytes()[at + 1] = uint8((value / 256) % 256)
                instance.bytes()[at + 2] = uint8((value / 65536) % 256)
                instance.bytes()[at + 3] = uint8((value / 16777216) % 256)
            }

            return(push(stored))
        }

        if (opcode == CVM.Opcode.ADD_I32 || opcode == CVM.Opcode.SUB_I32
                || opcode == CVM.Opcode.MUL_I32 || opcode
                == CVM.Opcode.DIV_I32 || opcode == CVM.Opcode.REM_I32) {
            return(binaryI32(opcode))
        }

        if (opcode == CVM.Opcode.NEG_I32) {
            Value operand = popType(Value.I32)
            if (operand == null || _failure != null) {
                return(false)
            }
            if (operand.number() == -2147483648) {
                trap(ExecutionResult.RUNTIME_TRAP, "i32 negation overflow")
                return(false)
            }
            return(push(Value(Value.I32, -operand.number(), null, true)))
        }

        if (opcode == CVM.Opcode.EQ_I32 || opcode == CVM.Opcode.NE_I32
                || opcode == CVM.Opcode.LT_I32 || opcode
                == CVM.Opcode.LE_I32 || opcode == CVM.Opcode.GT_I32
                || opcode == CVM.Opcode.GE_I32) {
            return(compareValues(opcode))
        }

        if (opcode == CVM.Opcode.TO_U8) {
            Value operand = popType(Value.I32)
            if (operand == null || _failure != null) {
                return(false)
            }
            if (operand.number() < 0 || operand.number() > 255) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "to.u8 value is outside 0..255")
                return(false)
            }
            return(push(Value(Value.U8, operand.number(), null, true)))
        }

        if (opcode == CVM.Opcode.TO_I32) {
            Value operand = popType(Value.U8)
            if (operand == null || _failure != null) {
                return(false)
            }
            return(push(Value(Value.I32, operand.number(), null, true)))
        }

        if (opcode == CVM.Opcode.DUP) {
            Value value = popAny()
            if (value == null || _failure != null) {
                return(false)
            }
            if (value.valueType() == Value.ARRAY_REF) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "dup does not accept ArrayRef")
                return(false)
            }
            if (!push(value)) {
                return(false)
            }
            return(push(value))
        }

        if (opcode == CVM.Opcode.POP) {
            Value value = popAny()
            if (value == null || _failure != null) {
                return(false)
            }
            if (value.valueType() == Value.ARRAY_REF) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "pop does not accept ArrayRef")
                return(false)
            }
            return(true)
        }

        if (opcode == CVM.Opcode.JMP || opcode == CVM.Opcode.JZ) {
            int64 target = readOperand(frame, function, 4)
            if (_failure != null) {
                return(false)
            }
            bool take = true
            if (opcode == CVM.Opcode.JZ) {
                Value condition = popType(Value.I32)
                if (condition == null || _failure != null) {
                    return(false)
                }
                take = condition.number() == 0
            }
            if (take) {
                if (target < 0 || target >= function.codeLength()) {
                    trap(
                            ExecutionResult.RUNTIME_TRAP,
                            "branch target is outside function code")
                    return(false)
                }
                frame.setPc(target)
            }
            return(true)
        }

        if (opcode == CVM.Opcode.CALL) {
            int64 target = readOperand(frame, function, 2)
            if (_failure != null) {
                return(false)
            }
            return(pushFrame(target, _activeOffset))
        }
        if (opcode == CVM.Opcode.RET) {
            return(doReturn(0))
        }
        if (opcode == CVM.Opcode.RET_I32) {
            return(doReturn(Value.I32))
        }
        if (opcode == CVM.Opcode.RET_U8) {
            return(doReturn(Value.U8))
        }
        if (opcode == CVM.Opcode.RET_FILE) {
            return(doReturn(Value.FILE))
        }
        if (opcode == CVM.Opcode.SYS) {
            int64 service = readOperand(frame, function, 1)
            if (_failure != null) {
                return(false)
            }
            return(executeService(service))
        }
        trap(ExecutionResult.RUNTIME_TRAP, format(
                "unknown opcode {}",
                opcode))
        return(false)
    }
}
