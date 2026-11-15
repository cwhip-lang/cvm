/*
 * modules/cvm/1.0.0/container_builder_1.cw — Out-of-line ContainerBuilder
 * methods, part 1.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Report whether this ContainerBuilder append all. Parameters: target is a
     * buffer; source is a buffer. It returns bool.
     */
    bool ContainerBuilder.appendAll(buffer target, buffer source) {
        int64 index = 0
        while (index < source.length) {
            target.append(source[index])
            index = index + 1
        }
        return(true)
    }

    /*
     * Compute section count for this ContainerBuilder. Parameters: section is
     * a Section. It returns int64.
     */
    int64 ContainerBuilder.sectionCount(Section section) {
        int64 kind = section.kind()
        if (kind == Format.CODE || kind == Format.TYPES || kind
                == Format.DATA || kind == Format.STRINGS) {
            return(section.bytes().length)
        }
        if (kind == Format.FUNCS) {
            return(_functions.length / Format.FUNCTION_SIZE)
        }
        if (kind == Format.GLOBALS) {
            return(_globals.length / Format.GLOBAL_SIZE)
        }
        if (kind == Format.ARRAYS) {
            return(_arrays.length / Format.ARRAY_SIZE)
        }
        return(section.count())
    }

    /*
     * Compute append string for this ContainerBuilder. Parameters: value is a
     * String. It returns int64.
     */
    int64 ContainerBuilder.appendString(String value) {
        int64 offset = _strings.length
        int64 index = 0
        while (index < value.length) {
            _strings.append(value[index])
            index = index + 1
        }
        _strings.append(0)
        return(offset)
    }

    /*
     * Report whether this ContainerBuilder valid identifier. Parameters: value
     * is a String. It returns bool.
     */
    bool ContainerBuilder.validIdentifier(String value) {
        if (value == null || value.length == 0) {
            return(false)
        }

        int64 index = 0
        while (index < value.length) {
            int64 current = int64(value[index])
            bool letter = (
                    (current >= 65 && current <= 90) || (current >= 97
                    && current <= 122) || current == 95)
            bool digit = current >= 48 && current <= 57
            if (index == 0 && !letter) {
                return(false)
            }
            if (index > 0 && !letter && !digit) {
                return(false)
            }
            index = index + 1
        }

        return(true)
    }

    /*
     * Report whether this ContainerBuilder fail. Parameters: code is an int64;
     * message is a String. It returns bool.
     */
    bool ContainerBuilder.fail(int64 code, String message) {
        if (_error == 0) {
            _error = code
            _message = message
        }
        return(false)
    }

    /*
     * Report whether this ContainerBuilder name exists. Parameters: names is a
     * list; value is a String. It returns bool.
     */
    bool ContainerBuilder.nameExists(list names, String value) {
        int64 index = 0
        while (index < names.length) {
            String previous = names[index] as String
            if (previous.equals(value)) {
                return(true)
            }
            index = index + 1
        }
        return(false)
    }

    /*
     * Construct a ContainerBuilder. It takes no parameters. It constructs a
     * ContainerBuilder.
     */
    ContainerBuilder ContainerBuilder.ContainerBuilder() {
        _sections = []
        _code = buffer[]
        _functions = buffer[]
        _types = buffer[]
        _globals = buffer[]
        _arrays = buffer[]
        _data = buffer[]
        _strings = buffer[]
        _debug = buffer[]
        _debugCount = 0
        _debugSet = false
        _optionalSections = []
        _functionNames = []
        _globalNames = []
        _arrayNames = []
        _entry = 0
        _error = 0
        _message = ""
        _sections.append(Section(Format.CODE, 0, 0, _code))
        _sections.append(Section(Format.FUNCS, 0, 0, _functions))
        _sections.append(Section(Format.TYPES, 0, 0, _types))
        _sections.append(Section(Format.GLOBALS, 0, 0, _globals))
        _sections.append(Section(Format.ARRAYS, 0, 0, _arrays))
        _sections.append(Section(Format.DATA, 0, 0, _data))
        _sections.append(Section(Format.STRINGS, 0, 0, _strings))
    }

    /*
     * Report whether this ContainerBuilder set entry. Parameters:
     * functionIndex is an int64. It returns bool.
     */
    bool ContainerBuilder.setEntry(int64 functionIndex) {
        if (_error != 0) {
            return(false)
        }
        if (functionIndex < 0 || functionIndex > 65534) {
            return(fail(INVALID_VALUE, "entry index is out of range"))
        }
        _entry = functionIndex
        return(true)
    }

    /*
     * Report whether this ContainerBuilder add function. Parameters: name is a
     * String; code is a buffer; localTypes is a buffer; parameterCount is an
     * int64; localCount is an int64; maximumStack is an int64; returnType is
     * an int64. It returns bool.
     */
    bool ContainerBuilder.addFunction(
            String name,
            buffer code,
            buffer localTypes,
            int64 parameterCount,
            int64 localCount,
            int64 maximumStack,
            int64 returnType) {
        if (_error != 0) {
            return(false)
        }
        if (!validIdentifier(name) || code == null || localTypes == null
                || code.length == 0 || parameterCount < 0 || parameterCount
                > 65535 || localCount < 0 || localCount > 65535
                || parameterCount + localCount > 65536 || localTypes.length
                != parameterCount + localCount || maximumStack < 0
                || maximumStack > 65535 || returnType < 0 || returnType
                > 3) {
            return(fail(INVALID_VALUE, "invalid function metadata"))
        }
        if (_functionNames.length >= 65535 || _code.length > 4294967295
                - code.length || _types.length > 4294967295
                - localTypes.length || _strings.length > 4294967295
                - name.length - 1) {
            return(fail(LIMIT_EXCEEDED, "function exceeds v1 limits"))
        }
        if (nameExists(_functionNames, name)) {
            return(fail(INVALID_VALUE, "duplicate function name"))
        }
        int64 index = 0
        while (index < localTypes.length) {
            int64 valueType = int64(localTypes[index])
            if (valueType < 1 || valueType > 3) {
                return(fail(
                        INVALID_VALUE,
                        "invalid function parameter/local type"))
            }
            index = index + 1
        }
        int64 nameOffset = appendString(name)
        _functionNames.append(name)
        ByteWriter record = ByteWriter()
        record.writeU32(uint64(nameOffset))
        record.writeU32(uint64(_code.length))
        record.writeU32(uint64(code.length))
        record.writeU32(uint64(_types.length))
        record.writeU16(parameterCount)
        record.writeU16(localCount)
        record.writeU16(maximumStack)
        record.writeU16(0)
        record.writeU8(returnType)
        record.writeU8(0)
        record.writeU8(0)
        record.writeU8(0)
        appendAll(_functions, record.bytes())
        appendAll(_types, localTypes)
        appendAll(_code, code)
        return(true)
    }

    /*
     * Report whether this ContainerBuilder add global. Parameters: name is a
     * String; valueType is an int64; initialValue is an int64. It returns
     * bool.
     */
    bool ContainerBuilder.addGlobal(String name, int64 valueType,
            int64 initialValue)
    {
        if (_error != 0) {
            return(false)
        }
        if (!validIdentifier(name) || nameExists(_globalNames, name) || (
                valueType != 1 && valueType != 2) || initialValue <
                -2147483648 || initialValue > 2147483647 || (valueType == 2
                && (
                initialValue < 0 || initialValue > 255))
                || _globals.length / Format.GLOBAL_SIZE >= 65536
                || _strings.length > 4294967295 - name.length - 1) {
            return(fail(INVALID_VALUE, "invalid global metadata"))
        }
        int64 nameOffset = appendString(name)
        _globalNames.append(name)
        ByteWriter record = ByteWriter()
        record.writeU32(uint64(nameOffset))
        record.writeU8(valueType)
        record.writeU8(0)
        record.writeU8(0)
        record.writeU8(0)
        record.writeI32(initialValue)
        appendAll(_globals, record.bytes())
        return(true)
    }

    /*
     * Report whether this ContainerBuilder add array. Parameters: name is a
     * String; ownerFunction is an int64; elementType is an int64; length is an
     * int64; initialData is a buffer. It returns bool.
     */
    bool ContainerBuilder.addArray(
            String name,
            int64 ownerFunction,
            int64 elementType,
            int64 length,
            buffer initialData) {
        if (_error != 0) {
            return(false)
        }
        if (!validIdentifier(name) || nameExists(_arrayNames, name)
                || (ownerFunction != 65535 && (
                ownerFunction < 0 || ownerFunction
                >= _functionNames.length)) || (
                elementType != 1 && elementType != 2) || length <= 0
                || length > 4294967295 || initialData == null
                || _arrays.length / Format.ARRAY_SIZE >= 65536
                || _strings.length > 4294967295 - name.length - 1) {
            return(fail(INVALID_VALUE, "invalid array metadata"))
        }
        int64 width = 1
        if (elementType == 1) {
            width = 4
        }
        if (initialData.length != 0 && (
                initialData.length != length * width || _data.length
                > 4294967295 - initialData.length)) {
            return(fail(
                    INVALID_VALUE,
                    "array initializer length is invalid"))
        }
        int64 nameOffset = appendString(name)
        _arrayNames.append(name)
        int64 flags = 1
        int64 dataOffset = _data.length
        if (initialData.length == 0) {
            flags = 0
            dataOffset = -1
        }
        ByteWriter record = ByteWriter()
        record.writeU32(uint64(nameOffset))
        record.writeU16(ownerFunction)
        record.writeU8(elementType)
        record.writeU8(flags)
        record.writeU32(uint64(length))
        if (flags == 0) {
            record.writeU32(4294967295u)
        }
        else {
            record.writeU32(uint64(dataOffset))
            appendAll(_data, initialData)
        }
        record.writeU32(0u)
        appendAll(_arrays, record.bytes())
        return(true)
    }
}
