/*
 * modules/cvmrun/1.0.0/virtual_machine_3.cw — Out-of-line VirtualMachine
 * methods, part 3.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Compute local type for this VirtualMachine. Parameters: function is a
     * FunctionInfo; index is an int64. It returns int64.
     */
    int64 VirtualMachine.localType(FunctionInfo function, int64 index) {
        if (index < 0 || index >= function.parameters()
                + function.locals()) {
            return(0)
        }
        return(int64(_types[function.typeOffset() + index]))
    }

    /*
     * Report default local for this VirtualMachine. The result is
     * Value(valueType, 0, null, false). Parameters: valueType is an int64. It
     * returns Value.
     */
    Value VirtualMachine.defaultLocal(int64 valueType) {
        return(Value(valueType, 0, null, false))
    }

    /*
     * Perform contextualize frame failure on this VirtualMachine. Parameters:
     * functionIndex is an int64. It does not return a value.
     */
    void VirtualMachine.contextualizeFrameFailure(int64 functionIndex) {
        if (_failure == null || _frames.length != 0 || functionIndex < 0
                || functionIndex >= _functions.length) {
            return
        }
        FunctionInfo function = _functions[functionIndex] as FunctionInfo
        _failure = ExecutionResult(_failure.category(), 0,
                _failure.message(),
            _failure.section(), _failure.byteOffset(), functionIndex,
            function.name(), 0, _steps)
    }

    /*
     * Report whether this VirtualMachine push frame. Parameters: functionIndex
     * is an int64; callOffset is an int64. It returns bool.
     */
    bool VirtualMachine.pushFrame(int64 functionIndex, int64 callOffset) {
        if (functionIndex < 0 || functionIndex >= _functions.length) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "call target function index is invalid")
            return(false)
        }
        if (_frames.length >= _limits.callDepth()) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                    "call depth limit exceeded")
            return(false)
        }
        FunctionInfo function = _functions[functionIndex] as FunctionInfo
        int64 argumentCount = function.parameters()
        Frame caller = currentFrame()
        int64 available = _stack.length
        if (caller != null) {
            available = available - caller.stackBase()
        }
        if (available < argumentCount) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "call argument stack underflow")
            return(false)
        }
        int64 argumentStart = _stack.length - argumentCount
        if (_activeSlots + _stack.length + function.locals()
                > _limits.stackValues()) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                    "active local and operand value limit exceeded")
            contextualizeFrameFailure(functionIndex)
            return(false)
        }

        int64 index = 0
        while (index < argumentCount) {
            Value argument = _stack[argumentStart + index] as Value
            if (argument == null || !argument.initialized()
                    || argument.valueType() != localType(
                    function,
                    index)) {
                trap(ExecutionResult.RUNTIME_TRAP,
                    format(
                        "call argument {} has the wrong type",
                        index))
                return(false)
            }
            index = index + 1
        }

        list locals = []
        index = 0
        while (index < argumentCount + function.locals()) {
            int64 slotType = localType(function, index)
            if (index < argumentCount) {
                locals.append(_stack[argumentStart + index])
            }
            else {
                locals.append(defaultLocal(slotType))
            }
            index = index + 1
        }
        Frame frame = (
                Frame(functionIndex, 0, argumentStart, callOffset, locals))
        list localIndexes = function.localArrayIndexes()
        index = 0

        while (index < localIndexes.length) {
            int64 arrayIndex = localIndexes[index] as int64
            ArrayInfo info = _arrayInfos[arrayIndex] as ArrayInfo
            ArrayInstance instance = createArray(arrayIndex, info)
            if (instance == null) {
                contextualizeFrameFailure(functionIndex)
                return(false)
            }
            frame.addArray(instance)
            index = index + 1
        }

        _stack.resize(argumentStart)
        _frames.append(frame)
        _activeSlots = _activeSlots + argumentCount + function.locals()
        return(true)
    }

    /*
     * Compute current frame for this VirtualMachine. It takes no parameters.
     * It returns Frame.
     */
    Frame VirtualMachine.currentFrame() {
        if (_frames.length == 0) {
            return(null)
        }
        return(_frames[_frames.length - 1] as Frame)
    }

    /*
     * Compute current function for this VirtualMachine. It takes no
     * parameters. It returns FunctionInfo.
     */
    FunctionInfo VirtualMachine.currentFunction() {
        Frame frame = currentFrame()
        if (frame == null) {
            return(null)
        }
        return(_functions[frame.functionIndex()] as FunctionInfo)
    }

    /*
     * Report whether this VirtualMachine push. Parameters: value is a Value.
     * It returns bool.
     */
    bool VirtualMachine.push(Value value) {
        Frame frame = currentFrame()
        if (frame == null) {
            trap(ExecutionResult.RUNTIME_TRAP, "missing execution frame")
            return(false)
        }
        if (_activeSlots + _stack.length >= _limits.stackValues()) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                    "active local and operand value limit exceeded")
            return(false)
        }
        FunctionInfo function = currentFunction()
        if (_stack.length - frame.stackBase() >= function.maximumStack()) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                    "function maximum stack declaration exceeded")
            return(false)
        }
        _stack.append(value)
        return(true)
    }

    /*
     * Compute pop any for this VirtualMachine. It takes no parameters. It
     * returns Value.
     */
    Value VirtualMachine.popAny() {
        Frame frame = currentFrame()
        if (frame == null || _stack.length <= frame.stackBase()) {
            trap(ExecutionResult.RUNTIME_TRAP, "operand stack underflow")
            return(null)
        }
        Value value = _stack[_stack.length - 1] as Value
        _stack.resize(_stack.length - 1)
        if (value == null || !value.initialized()) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "uninitialized operand stack value")
            return(null)
        }
        return(value)
    }

    /*
     * Compute pop type for this VirtualMachine. Parameters: expectedType is an
     * int64. It returns Value.
     */
    Value VirtualMachine.popType(int64 expectedType) {
        Value value = popAny()
        if (value == null || _failure != null) {
            return(null)
        }
        if (value.valueType() != expectedType) {
            trap(ExecutionResult.RUNTIME_TRAP,
                format("expected {}, found {}", typeName(expectedType),
                typeName(value.valueType())))
            return(null)
        }
        return(value)
    }

    /*
     * Compute type name for this VirtualMachine. Parameters: valueType is an
     * int64. It returns String.
     */
    String VirtualMachine.typeName(int64 valueType) {
        if (valueType == Value.I32) {
            return("i32")
        }
        if (valueType == Value.U8) {
            return("u8")
        }
        if (valueType == Value.FILE) {
            return("file")
        }
        if (valueType == Value.ARRAY_REF) {
            return("ArrayRef")
        }
        return("invalid value")
    }

    /*
     * Compute read code byte for this VirtualMachine. Parameters: frame is a
     * Frame; function is a FunctionInfo; relativeOffset is an int64. It
     * returns int64.
     */
    int64 VirtualMachine.readCodeByte(
            Frame frame,
            FunctionInfo function,
            int64 relativeOffset) {
        if (relativeOffset < 0 || relativeOffset
                >= function.codeLength()) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "instruction operand extends past function")
            return(0)
        }
        int64 absoluteOffset = function.codeOffset() + relativeOffset
        if (absoluteOffset < 0 || absoluteOffset >= _code.length) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "instruction offset is outside CODE")
            return(0)
        }
        return(int64(_code[absoluteOffset]))
    }

    /*
     * Compute read operand for this VirtualMachine. Parameters: frame is a
     * Frame; function is a FunctionInfo; width is an int64. It returns int64.
     */
    int64 VirtualMachine.readOperand(Frame frame, FunctionInfo function,
            int64 width)
    {
        int64 operandOffset = frame.pc()
        if (operandOffset < 0 || operandOffset > function.codeLength()
                || width > function.codeLength() - operandOffset) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "truncated instruction operand")
            return(0)
        }
        int64 value = 0
        if (width == 1) {
            value = readCodeByte(frame, function, operandOffset)
        }
        if (width == 2) {
            value = (
                    readCodeByte(frame, function, operandOffset)
                    + readCodeByte(frame, function, operandOffset + 1)
                    * 256)
        }
        if (width == 4) {
            value = (
                    readCodeByte(frame, function, operandOffset)
                    + readCodeByte(frame, function, operandOffset + 1)
                    * 256 + readCodeByte(frame, function, operandOffset
                    + 2) * 65536 + readCodeByte(frame, function,
                    operandOffset + 3) * 16777216)
        }
        if (_failure == null) {
            frame.setPc(operandOffset + width)
        }
        return(value)
    }
}
