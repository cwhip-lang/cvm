/*
 * modules/cvmrun/1.0.0/virtual_machine_2.cw — Out-of-line VirtualMachine
 * methods, part 2.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Report whether this VirtualMachine load. Parameters: decoded is a
     * CVM.ContainerDecodeResult. It returns bool.
     */
    bool VirtualMachine.load(CVM.ContainerDecodeResult decoded) {
        buffer functions = decoded.sectionBytes(CVM.Format.FUNCS)
        buffer globals = decoded.sectionBytes(CVM.Format.GLOBALS)
        buffer arrays = decoded.sectionBytes(CVM.Format.ARRAYS)
        buffer strings = decoded.sectionBytes(CVM.Format.STRINGS)
        _code = decoded.sectionBytes(CVM.Format.CODE)
        _types = decoded.sectionBytes(CVM.Format.TYPES)
        _data = decoded.sectionBytes(CVM.Format.DATA)
        _entry = decoded.entryFunction()
        if (functions == null || globals == null || arrays == null
                || strings == null || _code == null || _types == null
                || _data == null) {
            loadFailure(
                    0,
                    0,
                    "validated container is missing a required section")
            return(false)
        }

        if (functions.length % CVM.Format.FUNCTION_SIZE != 0
                || globals.length % CVM.Format.GLOBAL_SIZE != 0
                || arrays.length % CVM.Format.ARRAY_SIZE != 0) {
            loadFailure(0, 0, "record section has an invalid length")
            return(false)
        }
        if (functions.length / CVM.Format.FUNCTION_SIZE > 65535
                || globals.length / CVM.Format.GLOBAL_SIZE > 65536
                || arrays.length / CVM.Format.ARRAY_SIZE > 65536) {
            loadFailure(
                    0,
                    0,
                    "function, global, or array table exceeds v1 index limits")
            return(false)
        }

        int64 offset = 0
        while (offset < functions.length && _failure == null) {
            int64 nameOffset = u32At(functions, offset, CVM.Format.FUNCS)
            int64 codeOffset = (
                    u32At(functions, offset + 4, CVM.Format.FUNCS))
            int64 codeLength = (
                    u32At(functions, offset + 8, CVM.Format.FUNCS))
            int64 typeOffset = (
                    u32At(functions, offset + 12, CVM.Format.FUNCS))
            int64 parameters = (
                    u16At(functions, offset + 16, CVM.Format.FUNCS))
            int64 locals = u16At(functions, offset + 18, CVM.Format.FUNCS)
            int64 maximumStack = (
                    u16At(functions, offset + 20, CVM.Format.FUNCS))
            int64 returnType = (
                    byteAt(functions, offset + 24, CVM.Format.FUNCS))
            if (_failure != null) {
                return(false)
            }
            String name = nameAt(strings, nameOffset)
            if (_failure != null) {
                return(false)
            }
            if (parameters + locals > 65536 || codeLength <= 0
                    || codeOffset < 0 || codeOffset > _code.length
                    || codeLength > _code.length - codeOffset || typeOffset
                    < 0 || typeOffset > _types.length || parameters
                    + locals > _types.length - typeOffset || returnType < 0
                    || returnType > 3) {
                loadFailure(
                        CVM.Format.FUNCS,
                        offset,
                        "function metadata is outside its validated section")
                return(false)
            }

            int64 typeIndex = 0
            while (typeIndex < parameters + locals) {
                int64 valueType = int64(_types[typeOffset + typeIndex])
                if (valueType < Value.I32 || valueType > Value.FILE) {
                    loadFailure(
                            CVM.Format.TYPES,
                            typeOffset + typeIndex,
                            "invalid local or parameter type")
                    return(false)
                }
                typeIndex = typeIndex + 1
            }

            _functions.append(FunctionInfo(
                    name,
                    codeOffset,
                    codeLength,
                    typeOffset,
                parameters,
                    locals,
                    maximumStack,
                    returnType))
            offset = offset + CVM.Format.FUNCTION_SIZE
        }

        if (_failure != null) {
            return(false)
        }

        offset = 0

        while (offset < globals.length && _failure == null) {
            int64 valueType = (
                    byteAt(globals, offset + 4, CVM.Format.GLOBALS))
            int64 initial = i32At(globals, offset + 8, CVM.Format.GLOBALS)
            if (_failure != null) {
                return(false)
            }
            if ((valueType != Value.I32 && valueType != Value.U8)
                    || (valueType == Value.U8 && (
                    initial < 0 || initial > 255))) {
                loadFailure(
                        CVM.Format.GLOBALS,
                        offset + 4,
                        "invalid global type or initial value")
                return(false)
            }
            int64 reserved = (
                    byteAt(globals, offset + 5, CVM.Format.GLOBALS)
                    + byteAt(globals, offset + 6, CVM.Format.GLOBALS)
                    + byteAt(globals, offset + 7, CVM.Format.GLOBALS))
            if (_failure != null) {
                return(false)
            }
            if (reserved != 0) {
                loadFailure(
                        CVM.Format.GLOBALS,
                        offset + 5,
                        "global reserved bytes are nonzero")
                return(false)
            }
            _globals.append(Value(valueType, initial, null, true))
            offset = offset + CVM.Format.GLOBAL_SIZE
        }

        if (_failure != null) {
            return(false)
        }

        offset = 0

        while (offset < arrays.length && _failure == null) {
            int64 owner = u16At(arrays, offset + 4, CVM.Format.ARRAYS)
            int64 elementType = (
                    byteAt(arrays, offset + 6, CVM.Format.ARRAYS))
            int64 flags = byteAt(arrays, offset + 7, CVM.Format.ARRAYS)
            int64 length = u32At(arrays, offset + 8, CVM.Format.ARRAYS)
            int64 dataOffset = (
                    u32At(arrays, offset + 12, CVM.Format.ARRAYS))
            int64 reserved = u32At(arrays, offset + 16, CVM.Format.ARRAYS)
            if (_failure != null) {
                return(false)
            }
            if ((owner != 65535 && owner >= _functions.length) || (
                    elementType != Value.I32 && elementType != Value.U8)
                    || (
                    flags != 0 && flags != 1) || length <= 0 || reserved
                    != 0) {
                loadFailure(
                        CVM.Format.ARRAYS,
                        offset + 4,
                        "invalid array metadata")
                return(false)
            }
            int64 width = 1
            if (elementType == Value.I32) {
                width = 4
            }
            if (_limits.heapBytes() < Limits.ARRAY_INSTANCE_OVERHEAD
                    || length > (_limits.heapBytes()
                    - Limits.ARRAY_INSTANCE_OVERHEAD) / width) {
                failAt(
                        ExecutionResult.RESOURCE_LIMIT,
                    "array storage exceeds configured heap limit",
                    -1,
                        -1)
                return(false)
            }

            int64 storageBytes = length * width
            if (flags == 1) {
                if (dataOffset < 0 || dataOffset > _data.length
                        || storageBytes > _data.length - dataOffset) {
                    loadFailure(
                            CVM.Format.ARRAYS,
                            offset + 12,
                            "array initializer is outside DATA")
                    return(false)
                }

                int64 priorIndex = 0
                while (priorIndex < _arrayInfos.length) {

                    ArrayInfo prior = _arrayInfos[priorIndex] as ArrayInfo
                    if (prior.initialized()) {
                        int64 priorWidth = 1
                        if (prior.elementType() == Value.I32) {
                            priorWidth = 4
                        }
                        int64 priorBytes = prior.length() * priorWidth
                        if (dataOffset < prior.dataOffset() + priorBytes
                                && prior.dataOffset() < dataOffset
                                + storageBytes) {
                            loadFailure(
                                    CVM.Format.ARRAYS,
                                    offset + 12,
                                    "array initializer ranges overlap")
                            return(false)
                        }
                    }

                    priorIndex = priorIndex + 1
                }

            }
            else {
                if (dataOffset != 4294967295) {
                    loadFailure(
                            CVM.Format.ARRAYS,
                            offset + 12,
                            "uninitialized array has a data offset")
                    return(false)
                }
            }

            ArrayInfo info = (
                    ArrayInfo(owner, elementType, length, flags == 1,
                    dataOffset))
            _arrayInfos.append(info)

            if (owner == 65535) {
                ArrayInstance instance = (
                        createArray(_arrayInfos.length - 1, info))
                if (instance == null) {
                    return(false)
                }
                _globalArrays.append(instance)
            }
            else {
                FunctionInfo function = _functions[owner] as FunctionInfo
                function.addLocalArray(_arrayInfos.length - 1)
                _globalArrays.append(null)
            }

            offset = offset + CVM.Format.ARRAY_SIZE
        }

        if (_failure != null) {
            return(false)
        }
        if (_entry < 0 || _entry >= _functions.length) {
            loadFailure(
                    CVM.Format.FUNCS,
                    0,
                    "entry function index is invalid")
            return(false)
        }
        FunctionInfo entryFunction = _functions[_entry] as FunctionInfo
        if (!entryFunction.name().equals("main")
                || entryFunction.parameters() != 0
                || entryFunction.returnType() != Value.I32) {
            failAt(
                    ExecutionResult.LOAD_ERROR,
                "entry function must have signature main() -> i32",
                _entry,
                    -1)
            return(false)
        }
        return(true)
    }

    /*
     * Compute create array for this VirtualMachine. Parameters: index is an
     * int64; info is an ArrayInfo. It returns ArrayInstance.
     */
    ArrayInstance VirtualMachine.createArray(int64 index, ArrayInfo info) {
        int64 width = 1
        if (info.elementType() == Value.I32) {
            width = 4
        }
        if (info.length() > _limits.heapBytes() / width) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                    "array storage exceeds configured heap limit")
            return(null)
        }
        int64 size = info.length() * width
        int64 chargedBytes = size + Limits.ARRAY_INSTANCE_OVERHEAD
        if (chargedBytes > _limits.heapBytes() - _heapBytes) {
            trap(
                    ExecutionResult.RESOURCE_LIMIT,
                    "array storage exceeds configured heap limit")
            return(null)
        }
        buffer bytes = buffer(size)
        if (info.initialized()) {
            int64 indexInArray = 0
            while (indexInArray < size) {
                bytes[indexInArray] = (
                        _data[info.dataOffset() + indexInArray])
                indexInArray = indexInArray + 1
            }
        }
        _heapBytes = _heapBytes + chargedBytes
        return(ArrayInstance(
                index,
                info.elementType(),
                info.length(),
                bytes,
                chargedBytes))
    }
}
