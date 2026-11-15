/*
 * modules/cvmrun/1.0.0/virtual_machine_4.cw — Out-of-line VirtualMachine
 * methods, part 4.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Compute array for for this VirtualMachine. Parameters: frame is a Frame;
     * index is an int64. It returns ArrayInstance.
     */
    ArrayInstance VirtualMachine.arrayFor(Frame frame, int64 index) {
        if (index < 0 || index >= _arrayInfos.length) {
            trap(ExecutionResult.RUNTIME_TRAP, "array index is invalid")
            return(null)
        }

        ArrayInfo info = _arrayInfos[index] as ArrayInfo
        if (info.owner() == 65535) {
            if (index >= _globalArrays.length) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "global array storage is missing")
                return(null)
            }
            ArrayInstance instance = _globalArrays[index] as ArrayInstance
            if (instance == null || !instance.alive()) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "global array storage is unavailable")
                return(null)
            }
            return(instance)
        }

        if (info.owner() != frame.functionIndex()) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "array belongs to a different function")
            return(null)
        }

        list localIndexes = currentFunction().localArrayIndexes()
        list localArrays = frame.localArrays()
        int64 localIndex = 0
        while (localIndex < localIndexes.length) {
            if ((localIndexes[localIndex] as int64) == index) {
                if (localIndex >= localArrays.length) {
                    break
                }
                ArrayInstance instance = (
                        localArrays[localIndex] as ArrayInstance)
                if (instance == null || !instance.alive()) {
                    break
                }
                return(instance)
            }
            localIndex = localIndex + 1
        }

        trap(
                ExecutionResult.RUNTIME_TRAP,
                "local array storage is unavailable")
        return(null)
    }

    /*
     * Report whether this VirtualMachine valid array reference. Parameters:
     * value is a Value. It returns bool.
     */
    bool VirtualMachine.validArrayReference(Value value) {
        if (value == null || value.valueType() != Value.ARRAY_REF
                || value.array() == null || !value.array().alive()) {
            trap(
                    ExecutionResult.RUNTIME_TRAP,
                    "invalid or expired ArrayRef")
            return(false)
        }
        return(true)
    }

    /*
     * Report whether this VirtualMachine service available. Parameters:
     * enabled is a bool; serviceName is a String. It returns bool.
     */
    bool VirtualMachine.serviceAvailable(bool enabled, String serviceName) {
        if (!enabled) {
            trap(ExecutionResult.UNSUPPORTED_SERVICE,
                format(
                    "host capability for '{}' is disabled",
                    serviceName))
            return(false)
        }
        return(true)
    }

    /*
     * Compute open resource count for this VirtualMachine. It takes no
     * parameters. It returns int64.
     */
    int64 VirtualMachine.openResourceCount() {
        int64 count = _fileHandles.length
        if (_stdinOpen) {
            count = count + 1
        }
        return(count)
    }

    /*
     * Report whether this VirtualMachine check open resource limit. It takes
     * no parameters. It returns bool.
     */
    bool VirtualMachine.checkOpenResourceLimit() {
        if (openResourceCount() >= _capabilities.maxOpenFiles()) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                    "open file handle limit exceeded")
            return(false)
        }
        return(true)
    }

    /*
     * Compute find file handle for this VirtualMachine. Parameters: id is an
     * int64; integerHandle is a bool. It returns HostFile.
     */
    HostFile VirtualMachine.findFileHandle(int64 id, bool integerHandle) {
        int64 index = 0
        while (index < _fileHandles.length) {
            HostFile hostFile = _fileHandles[index] as HostFile
            if (hostFile != null && hostFile.open() && hostFile.id() == id
                    &&
                hostFile.integerHandle() == integerHandle) {
                return(hostFile)
            }
            index = index + 1
        }
        return(null)
    }

    /*
     * Perform remove file handle on this VirtualMachine. Parameters: removed
     * is a HostFile. It does not return a value.
     */
    void VirtualMachine.removeFileHandle(HostFile removed) {

        int64 index = 0
        while (index < _fileHandles.length) {
            HostFile hostFile = _fileHandles[index] as HostFile
            if (hostFile != null && hostFile.id() == removed.id()) {
                hostFile.invalidate()
                int64 last = _fileHandles.length - 1
                if (index != last) {
                    _fileHandles[index] = _fileHandles[last]
                }
                _fileHandles.resize(last)
                return()
            }
            index = index + 1
        }

        removed.invalidate()
    }

    /*
     * Report whether this VirtualMachine close file handle. Parameters:
     * hostFile is a HostFile; reportFailure is a bool. It returns bool.
     */
    bool VirtualMachine.closeFileHandle(HostFile hostFile, bool reportFailure)
    {
        String error = ""
        try {
            hostFile.file().close()
            error = Sys.System().lastError()
        }
        except(Exception) as caught {
            error = caught.message
        }
        removeFileHandle(hostFile)

        if (!error.equals("")) {
            if (reportFailure) {
                trap(ExecutionResult.IO_ERROR,
                    format("closing file handle {}: {}", hostFile.id(),
                    error))
            }
            else {
                failAt(ExecutionResult.IO_ERROR,
                    format("closing file handle {} during cleanup: {}",
                    hostFile.id(), error),
                    _entry, _activeOffset)
            }
            return(false)
        }

        return(true)
    }

    /*
     * Perform close owned resources on this VirtualMachine. It takes no
     * parameters. It does not return a value.
     */
    void VirtualMachine.closeOwnedResources() {
        while (_fileHandles.length > 0) {
            HostFile hostFile = (
                    _fileHandles[_fileHandles.length - 1] as HostFile)
            closeFileHandle(hostFile, false)
        }

        if (_stdinOpen) {
            String error = ""
            try {
                _stdinFile.close()
                error = Sys.System().lastError()
            }
            except(Exception) as caught {
                error = caught.message
            }
            _stdinFile = null
            _stdinOpen = false
            if (!error.equals("") && _failure == null) {
                failAt(ExecutionResult.IO_ERROR,
                    format(
                        "closing binary stdin during cleanup: {}",
                        error),
                    _entry, _activeOffset)
            }
        }
    }
}
