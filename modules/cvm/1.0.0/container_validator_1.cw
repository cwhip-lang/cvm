/*
 * modules/cvm/1.0.0/container_validator_1.cw — Out-of-line
 * ContainerValidator methods, part 1.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Compute find section for this ContainerValidator. Parameters: sections
     * is a list; kind is an int64. It returns Section.
     */
    Section ContainerValidator.findSection(list sections, int64 kind) {
        int64 index = 0
        while (index < sections.length) {
            Section section = sections[index] as Section
            if (section.kind() == kind) {
                return(section)
            }
            index = index + 1
        }
        return(null)
    }

    /*
     * Report reject for this ContainerValidator. The result is
     * ValidationResult(code, section, offset, message). Parameters: code is an
     * int64; section is an int64; offset is an int64; message is a String. It
     * returns ValidationResult.
     */
    ValidationResult ContainerValidator.reject(
            int64 code,
            int64 section,
            int64 offset,
            String message) {
        return(ValidationResult(code, section, offset, message))
    }

    /*
     * Report whether this ContainerValidator valid name. Parameters: bytes is
     * a buffer; stringsStart is an int64; stringsLength is an int64; offset is
     * an int64. It returns bool.
     */
    bool ContainerValidator.validName(
            buffer bytes,
            int64 stringsStart,
            int64 stringsLength,
            int64 offset) {
        if (offset < 0 || offset >= stringsLength) {
            return(false)
        }

        int64 cursor = stringsStart + offset
        int64 end = stringsStart + stringsLength
        bool first = true
        while (cursor < end) {
            int64 value = int64(bytes[cursor])
            if (value == 0) {
                return(!first)
            }
            bool letter = (
                    (value >= 65 && value <= 90) || (value >= 97 && value
                    <= 122) || value == 95)
            bool digit = value >= 48 && value <= 57
            if (first && !letter) {
                return(false)
            }
            if (!first && !letter && !digit) {
                return(false)
            }
            first = false
            cursor = cursor + 1
        }

        return(false)
    }

    /*
     * Report whether this ContainerValidator same name. Parameters: bytes is a
     * buffer; stringsStart is an int64; first is an int64; second is an int64.
     * It returns bool.
     */
    bool ContainerValidator.sameName(
            buffer bytes,
            int64 stringsStart,
            int64 first,
            int64 second) {
        int64 left = stringsStart + first
        int64 right = stringsStart + second
        while (int64(bytes[left]) == int64(bytes[right])) {
            if (int64(bytes[left]) == 0) {
                return(true)
            }
            left = left + 1
            right = right + 1
        }
        return(false)
    }
}
