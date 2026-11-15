/*
 * modules/cvm/1.0.0/validation_result.cw — Carry the structural validator's
 * code, section, byte offset, and message.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Carry the structural validator's code, section, byte offset, and
     * message.
     */
    class ValidationResult {
        private:
        int64 _code
        int64 _section
        int64 _offset
        String _message

        public:
        enum {
            OK = 0, TRUNCATED = 1, INVALID_MAGIC = 2,
            UNSUPPORTED_VERSION = 3, INVALID_HEADER = 4,
            INVALID_DIRECTORY = 5, INVALID_SECTION = 6,
            INVALID_INSTRUCTION = 7, INVALID_INDEX = 8,
            INVALID_RECORD = 9
        }

        ValidationResult(
                int64 code,
                int64 section,
                int64 offset,
                String message)

        bool valid()

        int64 code()

        int64 section()

        int64 offset()

        String message()

    }

    /*
     * Construct a ValidationResult and store its initial fields (_code,
     * _section, _offset, _message). Parameters: code is an int64; section is
     * an int64; offset is an int64; message is a String. It constructs a
     * ValidationResult.
     */
    ValidationResult ValidationResult.ValidationResult(
            int64 code,
            int64 section,
            int64 offset,
            String message) {
        _code = code
        _section = section
        _offset = offset
        _message = message
    }

    /*
     * Report valid for this ValidationResult. The result is _code == OK. It
     * takes no parameters. It returns bool.
     */
    bool ValidationResult.valid() {
        return(_code == OK)
    }

    /*
     * Report code for this ValidationResult. The result is _code. It takes no
     * parameters. It returns int64.
     */
    int64 ValidationResult.code() {
        return(_code)
    }

    /*
     * Report section for this ValidationResult. The result is _section. It
     * takes no parameters. It returns int64.
     */
    int64 ValidationResult.section() {
        return(_section)
    }

    /*
     * Report offset for this ValidationResult. The result is _offset. It takes
     * no parameters. It returns int64.
     */
    int64 ValidationResult.offset() {
        return(_offset)
    }

    /*
     * Report message for this ValidationResult. The result is _message. It
     * takes no parameters. It returns String.
     */
    String ValidationResult.message() {
        return(_message)
    }
}
