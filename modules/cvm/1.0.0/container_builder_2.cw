/*
 * modules/cvm/1.0.0/container_builder_2.cw — Out-of-line ContainerBuilder
 * methods, part 2.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Report whether this ContainerBuilder set debug. Parameters: records is a
     * buffer; count is an int64. It returns bool.
     */
    bool ContainerBuilder.setDebug(buffer records, int64 count) {
        if (_error != 0) {
            return(false)
        }
        if (_debugSet || records == null || count < 0 || count
                > 4294967295 / Format.DEBUG_SIZE || records.length != count
                * Format.DEBUG_SIZE) {
            return(fail(INVALID_VALUE, "invalid DEBUG section"))
        }
        _debug = records
        _debugCount = count
        _debugSet = true
        return(true)
    }

    /*
     * Report whether this ContainerBuilder add optional section. Parameters:
     * kind is an int64; bytes is a buffer; count is an int64. It returns bool.
     */
    bool ContainerBuilder.addOptionalSection(int64 kind, buffer bytes,
            int64 count)
    {
        if (_error != 0) {
            return(false)
        }
        if ((kind >= Format.CODE && kind <= Format.DEBUG) || kind < 0
                || kind > 65535 || bytes == null || count < 0 || count
                > 4294967295 || _optionalSections.length >= 65527) {
            return(fail(INVALID_VALUE, "invalid optional section"))
        }
        if (_optionalSections.length > 0) {
            Section previous = (
                    _optionalSections[_optionalSections.length
                    - 1] as Section)
            if (kind <= previous.kind()) {
                return(fail(
                        INVALID_VALUE,
                        "optional sections must be added in ascending kind order"))
            }
        }
        _optionalSections.append(Section(kind, 1, count, bytes))
        return(true)
    }

    /*
     * Report error code for this ContainerBuilder. The result is _error. It
     * takes no parameters. It returns int64.
     */
    int64 ContainerBuilder.errorCode() {
        return(_error)
    }

    /*
     * Report error message for this ContainerBuilder. The result is _message.
     * It takes no parameters. It returns String.
     */
    String ContainerBuilder.errorMessage() {
        return(_message)
    }

    /*
     * Compute encode for this ContainerBuilder. It takes no parameters. It
     * returns BuildResult.
     */
    BuildResult ContainerBuilder.encode() {
        if (_error != 0) {
            return(BuildResult(buffer[], _error, _message))
        }
        if (_functionNames.length == 0 || _entry
                >= _functionNames.length) {
            return(BuildResult(
                    buffer[],
                    INVALID_VALUE,
                    "entry function is missing"))
        }
        _sections = []
        int64 optionalIndex = 0
        while (optionalIndex < _optionalSections.length) {
            Section optional = _optionalSections[optionalIndex] as Section
            if (optional.kind() >= Format.CODE) {
                break
            }
            _sections.append(optional)
            optionalIndex = optionalIndex + 1
        }
        _sections.append(Section(Format.CODE, 0, 0, _code))
        _sections.append(Section(Format.FUNCS, 0, 0, _functions))
        _sections.append(Section(Format.TYPES, 0, 0, _types))
        _sections.append(Section(Format.GLOBALS, 0, 0, _globals))
        _sections.append(Section(Format.ARRAYS, 0, 0, _arrays))
        _sections.append(Section(Format.DATA, 0, 0, _data))
        _sections.append(Section(Format.STRINGS, 0, 0, _strings))
        if (_debugSet) {
            _sections.append(Section(Format.DEBUG, 1, _debugCount, _debug))
        }
        while (optionalIndex < _optionalSections.length) {
            _sections.append(_optionalSections[optionalIndex] as Section)
            optionalIndex = optionalIndex + 1
        }
        if (_sections.length > 65535) {
            return(BuildResult(
                    buffer[],
                    LIMIT_EXCEEDED,
                    "too many sections"))
        }

        int64 fileSize = (
                Format.HEADER_SIZE + _sections.length
                * Format.DIRECTORY_ENTRY_SIZE)
        list lengths = []
        int64 index = 0
        while (index < _sections.length) {
            Section section = _sections[index] as Section
            int64 size = section.bytes().length
            if (size > 4294967295 - fileSize) {
                return(BuildResult(
                        buffer[],
                        LIMIT_EXCEEDED,
                        "container exceeds v1 size limit"))
            }
            lengths.append(size)
            fileSize = fileSize + size
            index = index + 1
        }

        ByteWriter writer = ByteWriter()
        writer.writeU8(0x43)
        writer.writeU8(0x56)
        writer.writeU8(0x4d)
        writer.writeU8(0)
        writer.writeU16(Format.MAJOR_VERSION)
        writer.writeU16(Format.MINOR_VERSION)
        writer.writeU16(Format.HEADER_SIZE)
        writer.writeU16(0)
        writer.writeU16(_sections.length)
        writer.writeU16(0)
        writer.writeU32(uint64(_entry))
        writer.writeU32(uint64(Format.HEADER_SIZE))
        writer.writeU32(uint64(fileSize))
        writer.writeU32(uint64(0))
        int64 sectionOffset = (
                Format.HEADER_SIZE + _sections.length
                * Format.DIRECTORY_ENTRY_SIZE)
        index = 0

        while (index < _sections.length) {
            Section section = _sections[index] as Section
            int64 size = lengths[index] as int64
            writer.writeU16(section.kind())
            writer.writeU16(section.flags())
            writer.writeU32(uint64(sectionOffset))
            writer.writeU32(uint64(size))
            writer.writeU32(uint64(sectionCount(section)))
            sectionOffset = sectionOffset + size
            index = index + 1
        }

        index = 0
        while (index < _sections.length) {
            Section section = _sections[index] as Section
            appendAll(writer.bytes(), section.bytes())
            index = index + 1
        }
        if (writer.errorCode() != 0 || writer.bytes().length != fileSize) {
            return(BuildResult(
                    buffer[],
                    LIMIT_EXCEEDED,
                    "container encoding failed"))
        }
        ValidationResult validation = (
                ContainerValidator().validate(writer.bytes()))
        if (!validation.valid()) {
            return(BuildResult(buffer[], validation.code(),
                    validation.message()))
        }
        return(BuildResult(writer.bytes(), 0, ""))
    }
}
