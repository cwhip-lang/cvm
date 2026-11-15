/*
 * modules/cvmrun/1.0.0/virtual_machine.cw — Execute one v1 container. The
 * machine owns its stack, frames, heap arrays, and host files.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Execute one v1 container. The machine owns its stack, frames, heap
     * arrays, and host files.
     */
    class VirtualMachine {
        private:
        list _functions
        list _globals
        list _arrayInfos
        list _globalArrays
        list _frames
        list _stack
        buffer _code
        buffer _types
        buffer _data
        Limits _limits
        Capabilities _capabilities
        ExecutionResult _failure
        list _fileHandles
        Sys.File _stdinFile
        bool _stdinOpen
        int64 _nextFileHandle
        int64 _entry
        int64 _steps
        int64 _heapBytes
        int64 _activeSlots
        int64 _activeOffset
        int64 _guestResult
        bool _completed

        void reset(Limits limits)

        int64 byteAt(buffer bytes, int64 offset, int64 section)

        int64 u16At(buffer bytes, int64 offset, int64 section)

        int64 u32At(buffer bytes, int64 offset, int64 section)

        int64 i32At(buffer bytes, int64 offset, int64 section)

        void loadFailure(int64 section, int64 offset, String message)

        void validationFailure(CVM.ValidationResult validation)

        void failAt(
                int64 category,
                String message,
                int64 functionIndex,
                int64 offset)

        void trap(int64 category, String message)

        String nameAt(buffer strings, int64 offset)

        bool load(CVM.ContainerDecodeResult decoded)

        ArrayInstance createArray(int64 index, ArrayInfo info)

        int64 localType(FunctionInfo function, int64 index)

        Value defaultLocal(int64 valueType)

        void contextualizeFrameFailure(int64 functionIndex)

        bool pushFrame(int64 functionIndex, int64 callOffset)

        Frame currentFrame()

        FunctionInfo currentFunction()

        bool push(Value value)

        Value popAny()

        Value popType(int64 expectedType)

        String typeName(int64 valueType)

        int64 readCodeByte(
                Frame frame,
                FunctionInfo function,
                int64 relativeOffset)

        int64 readOperand(Frame frame, FunctionInfo function, int64 width)

        ArrayInstance arrayFor(Frame frame, int64 index)

        bool validArrayReference(Value value)

        bool serviceAvailable(bool enabled, String serviceName)

        int64 openResourceCount()

        bool checkOpenResourceLimit()

        HostFile findFileHandle(int64 id, bool integerHandle)

        void removeFileHandle(HostFile removed)

        bool closeFileHandle(HostFile hostFile, bool reportFailure)

        void closeOwnedResources()

        String decodePath(ArrayInstance instance)

        bool checkByteArrayRange(
                ArrayInstance instance,
                int64 offset,
                int64 count,
                                 bool allowZero,
                String operation)

        String decodeFileMode(ArrayInstance instance)

        bool checkIOError(String operation, String error)

        bool canPushServiceResult()

        bool executeService(int64 service)

        void freeFrame(Frame frame)

        bool doReturn(int64 returnType)

        bool compareValues(int64 opcode)

        bool binaryI32(int64 opcode)

        bool executeOne()

        public:
        ExecutionResult run(buffer program)

        ExecutionResult run(buffer program, Limits limits)

        ExecutionResult run(buffer program, Capabilities capabilities)

        ExecutionResult run(
                buffer program,
                Limits limits,
                Capabilities capabilities)

    }
}
