/*
 * modules/cvm/1.0.0/container_decode_result.cw — Expose a validated
 * container's entry, directory counts, and copied section bytes.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Expose a validated container's entry, directory counts, and copied
     * section bytes.
     */
    class ContainerDecodeResult {
        private:
        buffer _bytes
        ValidationResult _validation

        int64 directoryValue(int64 kind, int64 field)

        public:
        ContainerDecodeResult(buffer bytes, ValidationResult validation)

        bool valid()

        ValidationResult validation()

        int64 entryFunction()

        int64 directoryCount()

        int64 countForSection(int64 kind)

        buffer sectionBytes(int64 kind)

    }

    /*
     * Compute directory value for this ContainerDecodeResult. Parameters: kind
     * is an int64; field is an int64. It returns int64.
     */
    int64 ContainerDecodeResult.directoryValue(int64 kind, int64 field) {
        if (!valid()) {
            return(-1)
        }

        int64 index = 0
        ByteReader reader = ByteReader(_bytes)
        while (index < directoryCount()) {
            int64 at = (
                    Format.HEADER_SIZE + index
                    * Format.DIRECTORY_ENTRY_SIZE)
            reader.seek(at)
            int64 currentKind = reader.readU16()
            reader.readU16()
            int64 sectionOffset = reader.readU32()
            int64 sectionLength = reader.readU32()
            int64 count = reader.readU32()
            if (currentKind == kind) {
                if (field == 0) {
                    return(sectionOffset)
                }
                if (field == 1) {
                    return(sectionLength)
                }
                return(count)
            }
            index = index + 1
        }

        return(-1)
    }

    /*
     * Construct a ContainerDecodeResult and store its initial fields (_bytes,
     * _validation). Parameters: bytes is a buffer; validation is a
     * ValidationResult. It constructs a ContainerDecodeResult.
     */
    ContainerDecodeResult ContainerDecodeResult.ContainerDecodeResult(
            buffer bytes, ValidationResult validation)
    {
        _bytes = bytes
        _validation = validation
    }

    /*
     * Report valid for this ContainerDecodeResult. The result is
     * _validation.valid(). It takes no parameters. It returns bool.
     */
    bool ContainerDecodeResult.valid() {
        return(_validation.valid())
    }

    /*
     * Report validation for this ContainerDecodeResult. The result is
     * _validation. It takes no parameters. It returns ValidationResult.
     */
    ValidationResult ContainerDecodeResult.validation() {
        return(_validation)
    }

    /*
     * Compute entry function for this ContainerDecodeResult. It takes no
     * parameters. It returns int64.
     */
    int64 ContainerDecodeResult.entryFunction() {
        if (!valid()) {
            return(-1)
        }
        ByteReader reader = ByteReader(_bytes)
        reader.seek(16)
        return(reader.readU32())
    }

    /*
     * Compute directory count for this ContainerDecodeResult. It takes no
     * parameters. It returns int64.
     */
    int64 ContainerDecodeResult.directoryCount() {
        if (!valid()) {
            return(0)
        }
        ByteReader reader = ByteReader(_bytes)
        reader.seek(12)
        return(reader.readU16())
    }

    /*
     * Report count for section for this ContainerDecodeResult. The result is
     * directoryValue(kind, 2). Parameters: kind is an int64. It returns int64.
     */
    int64 ContainerDecodeResult.countForSection(int64 kind) {
        return(directoryValue(kind, 2))
    }

    /*
     * Compute section bytes for this ContainerDecodeResult. Parameters: kind
     * is an int64. It returns buffer.
     */
    buffer ContainerDecodeResult.sectionBytes(int64 kind) {
        int64 offset = directoryValue(kind, 0)
        int64 length = directoryValue(kind, 1)
        if (offset < 0 || length < 0) {
            return(null)
        }
        return(_bytes[offset:offset + length])
    }
}
