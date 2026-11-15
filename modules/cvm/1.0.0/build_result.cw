/*
 * modules/cvm/1.0.0/build_result.cw — Carry the bytes from a container
 * build, or the code and message of the failure.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Carry the bytes from a container build, or the code and message of the
     * failure.
     */
    class BuildResult {
        private:
        buffer _bytes
        int64 _code
        String _message

        public:
        BuildResult(buffer bytes, int64 code, String message)

        bool ok()

        buffer bytes()

        int64 code()

        String message()

    }

    /*
     * Construct a BuildResult and store its initial fields (_bytes, _code,
     * _message). Parameters: bytes is a buffer; code is an int64; message is a
     * String. It constructs a BuildResult.
     */
    BuildResult BuildResult.BuildResult(buffer bytes, int64 code,
            String message)
    {
        _bytes = bytes
        _code = code
        _message = message
    }

    /*
     * Report ok for this BuildResult. The result is _code == 0. It takes no
     * parameters. It returns bool.
     */
    bool BuildResult.ok() {
        return(_code == 0)
    }

    /*
     * Report bytes for this BuildResult. The result is _bytes. It takes no
     * parameters. It returns buffer.
     */
    buffer BuildResult.bytes() {
        return(_bytes)
    }

    /*
     * Report code for this BuildResult. The result is _code. It takes no
     * parameters. It returns int64.
     */
    int64 BuildResult.code() {
        return(_code)
    }

    /*
     * Report message for this BuildResult. The result is _message. It takes no
     * parameters. It returns String.
     */
    String BuildResult.message() {
        return(_message)
    }
}
