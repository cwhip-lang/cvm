/*
 * modules/cvm/1.0.0/container_validator_2.cw — Out-of-line
 * ContainerValidator methods, part 2.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Compute validate for this ContainerValidator. Parameters: bytes is a
     * buffer. It returns ValidationResult.
     */
    ValidationResult ContainerValidator.validate(buffer bytes) {
        if (bytes == null || bytes.length < Format.HEADER_SIZE) {
            return(reject(
                    ValidationResult.TRUNCATED,
                    0,
                    0,
                    "truncated header"))
        }
        ByteReader reader = ByteReader(bytes)
        if (reader.readU8() != 0x43 || reader.readU8() != 0x56
                || reader.readU8() != 0x4d || reader.readU8() != 0) {
            return(reject(
                    ValidationResult.INVALID_MAGIC,
                    0,
                    0,
                    "invalid CVM magic"))
        }
        int64 major = reader.readU16()
        int64 minor = reader.readU16()
        int64 headerSize = reader.readU16()
        int64 headerFlags = reader.readU16()
        int64 sectionCount = reader.readU16()
        int64 reserved16 = reader.readU16()
        int64 entry = reader.readU32()
        int64 directoryOffset = reader.readU32()
        int64 fileSize = reader.readU32()
        int64 reserved32 = reader.readU32()
        if (major != Format.MAJOR_VERSION || minor
                != Format.MINOR_VERSION) {
            return(reject(
                    ValidationResult.UNSUPPORTED_VERSION,
                    0,
                    4,
                    "unsupported bytecode version"))
        }
        if (headerSize != Format.HEADER_SIZE || headerFlags != 0
                || reserved16 != 0 || reserved32 != 0 || directoryOffset
                != Format.HEADER_SIZE || sectionCount < 7) {
            return(reject(
                    ValidationResult.INVALID_HEADER,
                    0,
                    8,
                    "invalid header fields"))
        }
        if (fileSize != bytes.length) {
            return(reject(
                    ValidationResult.INVALID_HEADER,
                    0,
                    24,
                    "file size differs from input length"))
        }
        if (sectionCount > (bytes.length
                - Format.HEADER_SIZE) / Format.DIRECTORY_ENTRY_SIZE) {
            return(reject(
                    ValidationResult.TRUNCATED,
                    0,
                    Format.HEADER_SIZE,
                    "truncated section directory"))
        }

        list sections = []
        int64 expectedOffset = (
                Format.HEADER_SIZE + sectionCount
                * Format.DIRECTORY_ENTRY_SIZE)
        int64 previousKind = -1
        int64 index = 0
        while (index < sectionCount) {
            int64 at = (
                    Format.HEADER_SIZE + index
                    * Format.DIRECTORY_ENTRY_SIZE)
            reader.seek(at)
            int64 kind = reader.readU16()
            int64 flags = reader.readU16()
            int64 offset = reader.readU32()
            int64 length = reader.readU32()
            int64 count = reader.readU32()
            if (kind <= previousKind) {
                return(reject(
                        ValidationResult.INVALID_DIRECTORY,
                        kind,
                        at,
                        "section kinds must be unique and ascending"))
            }
            if (offset != expectedOffset || offset > fileSize || length
                    > fileSize - offset) {
                return(reject(
                        ValidationResult.INVALID_SECTION,
                        kind,
                        at + 4,
                        "section extent is invalid"))
            }
            if (kind >= Format.CODE && kind <= Format.STRINGS && flags
                    != 0) {
                return(reject(
                        ValidationResult.INVALID_SECTION,
                        kind,
                        at + 2,
                        "required section flags must be zero"))
            }
            if (kind == Format.DEBUG && flags != 1) {
                return(reject(
                        ValidationResult.INVALID_SECTION,
                        kind,
                        at + 2,
                        "DEBUG must be optional"))
            }
            if ((kind < Format.CODE || kind > Format.DEBUG) && flags
                    != 1) {
                return(reject(
                        ValidationResult.INVALID_SECTION,
                        kind,
                        at + 2,
                        "unknown required section"))
            }
            int64 recordSize = 0
            if (kind == Format.FUNCS) {
                recordSize = Format.FUNCTION_SIZE
            }
            if (kind == Format.GLOBALS) {
                recordSize = Format.GLOBAL_SIZE
            }
            if (kind == Format.ARRAYS) {
                recordSize = Format.ARRAY_SIZE
            }
            if (kind == Format.DEBUG) {
                recordSize = Format.DEBUG_SIZE
            }

            if (recordSize == 0) {
                if (kind >= Format.CODE && kind <= Format.STRINGS && count
                        != length) {
                    return(reject(
                            ValidationResult.INVALID_SECTION,
                            kind,
                            at + 12,
                            "byte count differs from section length"))
                }
            }
            else {
                if (count > 4294967295 / recordSize || count * recordSize
                        != length) {
                    return(reject(
                            ValidationResult.INVALID_SECTION,
                            kind,
                            at + 8,
                            "record count differs from section length"))
                }
            }

            sections.append(Section(kind, flags, count, buffer[]))
            Section current = sections[sections.length - 1] as Section
            current.setExtent(offset, length)
            expectedOffset = offset + length
            previousKind = kind
            index = index + 1
        }

        if (expectedOffset != fileSize) {
            return(reject(
                    ValidationResult.INVALID_SECTION,
                    0,
                    expectedOffset,
                    "last section does not end at file size"))
        }
        index = 1
        while (index <= 7) {
            if (findSection(sections, index) == null) {
                return(reject(
                        ValidationResult.INVALID_DIRECTORY,
                        index,
                        Format.HEADER_SIZE,
                        "required section is missing"))
            }
            index = index + 1
        }
        Section code = findSection(sections, Format.CODE)
        Section functions = findSection(sections, Format.FUNCS)
        Section types = findSection(sections, Format.TYPES)
        Section globals = findSection(sections, Format.GLOBALS)
        Section arrays = findSection(sections, Format.ARRAYS)
        Section strings = findSection(sections, Format.STRINGS)
        if (functions.count() > 65535 || globals.count() > 65536
                || arrays.count() > 65536) {
            return(reject(
                    ValidationResult.INVALID_SECTION,
                    0,
                    Format.HEADER_SIZE,
                    "table exceeds v1 index limits"))
        }
        if (functions.count() == 0 || entry >= functions.count()) {
            return(reject(
                    ValidationResult.INVALID_INDEX,
                    Format.FUNCS,
                    16,
                    "entry function index is invalid"))
        }
        buffer boundaries = buffer(code.length())
        list branches = []
        list functionNames = []
        int64 nextCode = 0
        index = 0

        while (index < functions.count()) {
            int64 at = functions.offset() + index * Format.FUNCTION_SIZE
            reader.seek(at)
            int64 nameOffset = reader.readU32()
            int64 codeOffset = reader.readU32()
            int64 codeLength = reader.readU32()
            int64 typeOffset = reader.readU32()
            int64 parameterCount = reader.readU16()
            int64 localCount = reader.readU16()
            int64 maximumStack = reader.readU16()
            int64 functionFlags = reader.readU16()
            int64 returnType = reader.readU8()
            int64 r0 = reader.readU8()
            int64 r1 = reader.readU8()
            int64 r2 = reader.readU8()
            int64 slots = parameterCount + localCount
            if (codeLength == 0 || codeOffset != nextCode || codeOffset
                    > code.length() || codeLength > code.length()
                    - codeOffset) {
                return(reject(
                        ValidationResult.INVALID_RECORD,
                        Format.FUNCS,
                        at + 4,
                        "function code extent is invalid"))
            }
            if (slots > 65536 || typeOffset > types.length() || slots
                    > types.length() - typeOffset || returnType > 3
                    || functionFlags != 0 || r0 != 0 || r1 != 0 || r2
                    != 0) {
                return(reject(
                        ValidationResult.INVALID_RECORD,
                        Format.FUNCS,
                        at + 12,
                        "function metadata is invalid"))
            }

            if (!validName(
                    bytes,
                    strings.offset(),
                    strings.length(),
                    nameOffset)) {
                return(reject(
                        ValidationResult.INVALID_RECORD,
                        Format.FUNCS,
                        at,
                        "function name is not a valid ASCII identifier"))
            }

            int64 nameIndex = 0
            while (nameIndex < functionNames.length) {

                int64 previousName = functionNames[nameIndex] as int64
                if (sameName(
                        bytes,
                        strings.offset(),
                        previousName,
                        nameOffset)) {
                    return(reject(
                            ValidationResult.INVALID_RECORD,
                            Format.FUNCS,
                            at,
                            "function name is duplicated"))
                }

                nameIndex = nameIndex + 1
            }

            functionNames.append(nameOffset)

            int64 typeIndex = 0
            while (typeIndex < slots) {
                int64 valueType = (
                        int64(bytes[types.offset() + typeOffset
                        + typeIndex]))
                if (valueType < 1 || valueType > 3) {
                    return(reject(
                            ValidationResult.INVALID_RECORD,
                            Format.TYPES,
                            typeOffset + typeIndex,
                            "invalid function parameter/local type"))
                }
                typeIndex = typeIndex + 1
            }

            int64 cursor = 0
            while (cursor < codeLength) {
                boundaries[codeOffset + cursor] = uint8(1)
                int64 instructionAt = code.offset() + codeOffset + cursor
                reader.seek(instructionAt)
                int64 opcode = reader.readU8()
                Opcode schema = Opcode()
                if (!schema.isValid(opcode)) {
                    return(reject(
                            ValidationResult.INVALID_INSTRUCTION,
                            Format.CODE,
                            instructionAt,
                            "unknown opcode"))
                }
                int64 width = schema.operandWidth(opcode)
                if (width > codeLength - cursor - 1) {
                    return(reject(
                            ValidationResult.TRUNCATED,
                            Format.CODE,
                            instructionAt,
                            "truncated instruction operand"))
                }
                int64 kind = schema.operandKind(opcode)
                int64 operand = 0
                if (width == 1) {
                    operand = reader.readU8()
                }
                if (width == 2) {
                    operand = reader.readU16()
                }
                if (width == 4) {
                    operand = reader.readU32()
                }
                if (kind == 2 && opcode == Opcode.SYS && operand
                        > Service.FILE_CLOSE_HANDLE) {
                    return(reject(
                            ValidationResult.INVALID_INDEX,
                            Format.CODE,
                            instructionAt + 1,
                            "unknown service number"))
                }
                if ((kind == 3 && operand >= slots) || (kind == 4
                        && operand >= globals.count()) || (kind == 5
                        && operand >= arrays.count()) || (kind == 7
                        && operand >= functions.count())) {
                    return(reject(
                            ValidationResult.INVALID_INDEX,
                            Format.CODE,
                            instructionAt + 1,
                            "instruction index is invalid"))
                }
                if (kind == 6) {
                    if (operand >= codeLength) {
                        return(reject(
                                ValidationResult.INVALID_INDEX,
                                Format.CODE,
                                instructionAt + 1,
                                "branch target outside function"))
                    }
                    branches.append(BranchTarget(codeOffset, operand))
                }
                cursor = cursor + 1 + width
            }

            nextCode = codeOffset + codeLength
            index = index + 1
        }

        if (nextCode != code.length()) {
            return(reject(ValidationResult.INVALID_RECORD, Format.FUNCS,
                    functions.offset(),
                    "function code does not cover CODE"))
        }
        index = 0
        while (index < branches.length) {
            BranchTarget branch = branches[index] as BranchTarget
            if (int64(boundaries[branch.functionOffset()
                    + branch.target()]) == 0) {
                return(reject(ValidationResult.INVALID_INDEX, Format.CODE,
                        code.offset() + branch.functionOffset()
                        + branch.target(),
                        "branch target is not an instruction boundary"))
            }
            index = index + 1
        }
        return(ValidationResult(ValidationResult.OK, 0, -1, ""))
    }
}
