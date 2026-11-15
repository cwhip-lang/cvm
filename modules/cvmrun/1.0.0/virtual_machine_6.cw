/*
 * modules/cvmrun/1.0.0/virtual_machine_6.cw — Out-of-line VirtualMachine
 * methods, part 6.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Report whether this VirtualMachine execute service. Parameters: service
     * is an int64. It returns bool.
     */
    bool VirtualMachine.executeService(int64 service) {
        CVM.Service schema = CVM.Service()
        String serviceName = schema.name(service)
        if (serviceName.equals("")) {
            trap(ExecutionResult.RUNTIME_TRAP,
                format(
                    "invalid host service {}",
                    service))
            return(false)
        }

        if (service == CVM.Service.STDOUT_I32) {
            Value value = popType(Value.I32)
            if (value == null || _failure != null) {
                return(false)
            }
            if (!serviceAvailable(
                    _capabilities.stdoutEnabled(),
                    serviceName)) {
                return(false)
            }
            String text = format("{}", value.number())
            Sys.StandardIO io = Sys.StandardIO()
            int64 written = -1
            String error = ""
            try {
                written = io.write(text)
                error = Sys.System().lastError()
                if (error.equals("") && written == text.length) {
                    io.flush()
                    error = Sys.System().lastError()
                }
            }
            except(Exception) as caught {
                error = caught.message
            }
            if (!checkIOError("writing stdout", error)) {
                return(false)
            }
            if (written != text.length) {
                trap(
                        ExecutionResult.IO_ERROR,
                        "writing stdout made incomplete progress")
                return(false)
            }
            return(true)
        }

        if (service == CVM.Service.STDOUT_BYTE) {
            Value value = popType(Value.U8)
            if (value == null || _failure != null) {
                return(false)
            }
            if (!serviceAvailable(
                    _capabilities.stdoutEnabled(),
                    serviceName)) {
                return(false)
            }
            buffer bytes = buffer(1)
            bytes[0] = uint8(value.number())
            Sys.StandardIO io = Sys.StandardIO()
            int64 written = -1
            String error = ""
            try {
                written = io.writeBytes(bytes)
                error = Sys.System().lastError()
                if (error.equals("") && written == 1) {
                    io.flush()
                    error = Sys.System().lastError()
                }
            }
            except(Exception) as caught {
                error = caught.message
            }
            if (!checkIOError("writing stdout byte", error)) {
                return(false)
            }
            if (written != 1) {
                trap(
                        ExecutionResult.IO_ERROR,
                        "writing stdout byte made incomplete progress")
                return(false)
            }
            return(true)
        }

        if (service == CVM.Service.STDOUT_WRITE) {
            Value countValue = popType(Value.I32)
            if (countValue == null || _failure != null) {
                return(false)
            }
            Value offsetValue = popType(Value.I32)
            if (offsetValue == null || _failure != null) {
                return(false)
            }
            Value reference = popType(Value.ARRAY_REF)
            if (reference == null || _failure != null
                    || !validArrayReference(
                    reference)) {
                return(false)
            }
            int64 offset = offsetValue.number()
            int64 count = countValue.number()
            ArrayInstance instance = reference.array()
            if (!checkByteArrayRange(
                    instance,
                    offset,
                    count,
                    true,
                    "stdout_write")) {
                return(false)
            }
            if (!serviceAvailable(
                    _capabilities.stdoutEnabled(),
                    serviceName)) {
                return(false)
            }
            if (!canPushServiceResult()) {
                return(false)
            }
            if (count == 0) {
                return(push(Value(Value.I32, 0, null, true)))
            }
            buffer chunk = instance.bytes()[offset:offset + count]
            Sys.StandardIO io = Sys.StandardIO()
            int64 written = -1
            String error = ""
            try {
                written = io.writeBytes(chunk)
                error = Sys.System().lastError()
                if (error.equals("") && written > 0) {
                    io.flush()
                    error = Sys.System().lastError()
                }
            }
            except(Exception) as caught {
                error = caught.message
            }
            if (!checkIOError("writing stdout bytes", error)) {
                return(false)
            }
            if (written <= 0 || written > count) {
                trap(
                        ExecutionResult.IO_ERROR,
                        "stdout write made invalid progress")
                return(false)
            }
            return(push(Value(Value.I32, written, null, true)))
        }

        if (service == CVM.Service.STDIN_BYTE) {
            if (!serviceAvailable(_capabilities.stdinEnabled(),
                    serviceName)) {
                return(false)
            }
            if (!canPushServiceResult()) {
                return(false)
            }

            if (!_stdinOpen) {
                if (!checkOpenResourceLimit()) {
                    return(false)
                }
                try {
                    _stdinFile = Sys.File("/dev/stdin", "rb")
                    _stdinOpen = true
                }
                except(Exception) as caught {
                    trap(ExecutionResult.IO_ERROR,
                        format(
                            "opening binary stdin: {}",
                            caught.message))
                    return(false)
                }
            }

            buffer byte = buffer[]
            String error = ""
            try {
                byte = _stdinFile.readBytes(1)
                error = Sys.System().lastError()
            }
            except(Exception) as caught {
                error = caught.message
            }
            if (!checkIOError("reading stdin byte", error)) {
                return(false)
            }
            if (byte == null || byte.length > 1) {
                trap(
                        ExecutionResult.IO_ERROR,
                        "stdin byte read returned invalid data")
                return(false)
            }
            if (byte.length == 1) {
                return(push(Value(Value.I32, int64(byte[0]), null, true)))
            }
            bool atEnd = false
            try {
                atEnd = _stdinFile.eof()
                error = Sys.System().lastError()
            }
            except(Exception) as caught {
                error = caught.message
            }
            if (!checkIOError("checking stdin EOF", error)) {
                return(false)
            }
            if (!atEnd) {
                trap(
                        ExecutionResult.IO_ERROR,
                        "stdin read made no progress before EOF")
                return(false)
            }
            return(push(Value(Value.I32, -1, null, true)))
        }

        if (service == CVM.Service.FILE_OPEN_READ ||
            service == CVM.Service.FILE_OPEN_WRITE || service
            == CVM.Service.FILE_OPEN) {
            bool integerHandle = service == CVM.Service.FILE_OPEN
            String mode = "rb"
            if (service == CVM.Service.FILE_OPEN_WRITE) {
                mode = "wb"
            }

            if (integerHandle) {
                Value modeReference = popType(Value.ARRAY_REF)
                if (modeReference == null || _failure != null ||
                    !validArrayReference(
                        modeReference)) {
                    return(false)
                }
                mode = decodeFileMode(modeReference.array())
                if (mode == null || _failure != null) {
                    return(false)
                }
            }

            Value reference = popType(Value.ARRAY_REF)
            if (reference == null || _failure != null
                    || !validArrayReference(
                    reference)) {
                return(false)
            }
            String path = decodePath(reference.array())
            if (path == null || _failure != null) {
                return(false)
            }
            if (!serviceAvailable(_capabilities.filesEnabled(),
                    serviceName)) {
                return(false)
            }
            if (!checkOpenResourceLimit()) {
                return(false)
            }
            if (!canPushServiceResult()) {
                return(false)
            }
            if (_nextFileHandle > 2147483647) {
                trap(
                        ExecutionResult.RESOURCE_LIMIT,
                        "file handle identifier space exhausted")
                return(false)
            }
            Sys.File file = null
            try {
                file = Sys.File(path, mode)
            }
            except(Exception) as caught {
                trap(ExecutionResult.IO_ERROR,
                    format(
                        "opening '{}': {}",
                        path,
                        caught.message))
                return(false)
            }
            int64 handleId = _nextFileHandle
            _nextFileHandle = _nextFileHandle + 1
            _fileHandles.append(HostFile(handleId, file, integerHandle))
            int64 resultType = Value.FILE
            if (integerHandle) {
                resultType = Value.I32
            }
            return(push(Value(resultType, handleId, null, true)))
        }

        if (service == CVM.Service.FILE_READ || service
                == CVM.Service.FILE_READ_HANDLE) {
            bool integerHandle = service == CVM.Service.FILE_READ_HANDLE
            Value capacityValue = popType(Value.I32)
            if (capacityValue == null || _failure != null) {
                return(false)
            }
            int64 offset = 0
            if (!integerHandle) {
                Value offsetValue = popType(Value.I32)
                if (offsetValue == null || _failure != null) {
                    return(false)
                }
                offset = offsetValue.number()
            }
            Value reference = popType(Value.ARRAY_REF)
            if (reference == null || _failure != null
                    || !validArrayReference(
                    reference)) {
                return(false)
            }
            int64 handleType = Value.FILE
            if (integerHandle) {
                handleType = Value.I32
            }
            Value fileValue = popType(handleType)
            if (fileValue == null || _failure != null) {
                return(false)
            }
            int64 capacity = capacityValue.number()
            ArrayInstance instance = reference.array()
            if (!checkByteArrayRange(
                    instance,
                    offset,
                    capacity,
                    integerHandle,
                    serviceName)) {
                return(false)
            }
            HostFile hostFile = (
                    findFileHandle(fileValue.number(), integerHandle))
            if (hostFile == null) {
                trap(ExecutionResult.RUNTIME_TRAP,
                    format("invalid, stale, or foreign file handle {}",
                    fileValue.number()))
                return(false)
            }
            if (!canPushServiceResult()) {
                return(false)
            }
            if (capacity == 0) {
                return(push(Value(Value.I32, 0, null, true)))
            }
            buffer bytes = buffer[]
            String error = ""
            try {
                bytes = hostFile.file().readBytes(capacity)
                error = Sys.System().lastError()
            }
            except(Exception) as caught {
                error = caught.message
            }
            if (!checkIOError("reading file", error)) {
                return(false)
            }
            if (bytes == null || bytes.length > capacity) {
                trap(
                        ExecutionResult.IO_ERROR,
                        "file read returned invalid byte count")
                return(false)
            }

            if (integerHandle && bytes.length == 0) {
                bool atEnd = false
                try {
                    atEnd = hostFile.file().eof()
                    error = Sys.System().lastError()
                }
                except(Exception) as caught {
                    error = caught.message
                }
                if (!checkIOError("checking file EOF", error)) {
                    return(false)
                }
                if (!atEnd) {
                    trap(
                            ExecutionResult.IO_ERROR,
                            "file read made no progress before EOF")
                    return(false)
                }
            }

            int64 index = 0
            while (index < bytes.length) {
                instance.bytes()[offset + index] = bytes[index]
                index = index + 1
            }
            return(push(Value(Value.I32, bytes.length, null, true)))
        }

        if (service == CVM.Service.FILE_WRITE || service
                == CVM.Service.FILE_WRITE_HANDLE) {
            bool integerHandle = service == CVM.Service.FILE_WRITE_HANDLE
            Value countValue = popType(Value.I32)
            if (countValue == null || _failure != null) {
                return(false)
            }
            int64 offset = 0
            if (!integerHandle) {
                Value offsetValue = popType(Value.I32)
                if (offsetValue == null || _failure != null) {
                    return(false)
                }
                offset = offsetValue.number()
            }
            Value reference = popType(Value.ARRAY_REF)
            if (reference == null || _failure != null
                    || !validArrayReference(
                    reference)) {
                return(false)
            }
            int64 handleType = Value.FILE
            if (integerHandle) {
                handleType = Value.I32
            }
            Value fileValue = popType(handleType)
            if (fileValue == null || _failure != null) {
                return(false)
            }
            int64 count = countValue.number()
            ArrayInstance instance = reference.array()
            if (!checkByteArrayRange(
                    instance,
                    offset,
                    count,
                    true,
                    serviceName)) {
                return(false)
            }
            HostFile hostFile = (
                    findFileHandle(fileValue.number(), integerHandle))
            if (hostFile == null) {
                trap(ExecutionResult.RUNTIME_TRAP,
                    format("invalid, stale, or foreign file handle {}",
                    fileValue.number()))
                return(false)
            }
            if (!canPushServiceResult()) {
                return(false)
            }
            if (count == 0) {
                return(push(Value(Value.I32, 0, null, true)))
            }
            buffer chunk = instance.bytes()[offset:offset + count]
            int64 written = -1
            String error = ""
            try {
                written = hostFile.file().writeBytes(chunk)
                error = Sys.System().lastError()
            }
            except(Exception) as caught {
                error = caught.message
            }
            if (!checkIOError("writing file", error)) {
                return(false)
            }
            if (written <= 0 || written > count) {
                trap(
                        ExecutionResult.IO_ERROR,
                        "file write made invalid progress")
                return(false)
            }
            return(push(Value(Value.I32, written, null, true)))
        }

        if (service == CVM.Service.FILE_CLOSE || service
                == CVM.Service.FILE_CLOSE_HANDLE) {
            bool integerHandle = service == CVM.Service.FILE_CLOSE_HANDLE
            int64 handleType = Value.FILE
            if (integerHandle) {
                handleType = Value.I32
            }
            Value fileValue = popType(handleType)
            if (fileValue == null || _failure != null) {
                return(false)
            }
            HostFile hostFile = (
                    findFileHandle(fileValue.number(), integerHandle))
            if (hostFile == null) {
                trap(ExecutionResult.RUNTIME_TRAP,
                    format("invalid, stale, or foreign file handle {}",
                    fileValue.number()))
                return(false)
            }
            return(closeFileHandle(hostFile, true))
        }

        trap(ExecutionResult.RUNTIME_TRAP,
            format(
                "invalid host service {}",
                service))
        return(false)
    }
}
