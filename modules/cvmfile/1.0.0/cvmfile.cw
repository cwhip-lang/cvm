/*
 * modules/cvmfile/1.0.0/cvmfile.cw — Installable cvmfile package. It reads
 * and writes container bytes.
 *
 * Created: 2026-10-22
 * Author: Charles Tilbury
 *
 * Changelog:
 *   2026-10-22  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import system as Sys

namespace CVMFile {
    /*
     * Own the bytes or the error string from one cvmfile read or write.
     */
    class Result {
        private:
        buffer _bytes
        String _error
        int64 _category

        public:
        enum {
            OK = 0, IO_ERROR = 1, LIMIT_EXCEEDED = 2
        }

        Result(buffer bytes, String error)

        Result(buffer bytes, String error, int64 category)

        bool ok()

        buffer bytes()

        String error()

        int64 category()

    }

    /*
     * Construct a Result. Parameters: bytes is a buffer; error is a String. It
     * constructs a Result.
     */
    Result Result.Result(buffer bytes, String error) {
        _bytes = bytes
        _error = error
        _category = IO_ERROR
        if (_error.equals("")) {
            _category = OK
        }
    }

    /*
     * Construct a Result and store its initial fields (_bytes, _error,
     * _category). Parameters: bytes is a buffer; error is a String; category
     * is an int64. It constructs a Result.
     */
    Result Result.Result(buffer bytes, String error, int64 category) {
        _bytes = bytes
        _error = error
        _category = category
    }

    /*
     * Report ok for this Result. The result is _error.equals(""). It takes no
     * parameters. It returns bool.
     */
    bool Result.ok() {
        return(_error.equals(""))
    }

    /*
     * Report bytes for this Result. The result is _bytes. It takes no
     * parameters. It returns buffer.
     */
    buffer Result.bytes() {
        return(_bytes)
    }

    /*
     * Report error for this Result. The result is _error. It takes no
     * parameters. It returns String.
     */
    String Result.error() {
        return(_error)
    }

    /*
     * Report category for this Result. The result is _category. It takes no
     * parameters. It returns int64.
     */
    int64 Result.category() {
        return(_category)
    }

    /*
     * Read and write whole byte buffers through the public SDK file API,
     * including partial transfers.
     */
    class Files {
        public:
        Result read(String path)

        Result readLimited(String path, int64 maximumBytes)

        Result write(String path, buffer bytes)

    }

    /*
     * Report read for this Files. The result is readLimited(path,
     * 9223372036854775807). Parameters: path is a String. It returns Result.
     */
    Result Files.read(String path) {
        return(readLimited(path, 9223372036854775807))
    }

    /*
     * Compute read limited for this Files. Parameters: path is a String;
     * maximumBytes is an int64. It returns Result.
     */
    Result Files.readLimited(String path, int64 maximumBytes) {
        if (maximumBytes < 0) {
            return(Result(buffer[],
                    "maximum read size cannot be negative"))
        }
        Sys.File file = null
        try {
            file = Sys.File(path, "rb")
        }
        except(Exception) as error {
            return(Result(buffer[], error.message))
        }
        buffer bytes = buffer[]
        String failure = ""
        bool limitExceeded = false
        try {

            bool finished = false
            while (!finished && failure.equals("")) {
                int64 requestSize = 65536
                int64 remaining = maximumBytes - bytes.length
                if (remaining < requestSize) {
                    requestSize = remaining + 1
                }
                buffer part = file.readBytes(requestSize)
                failure = Sys.System().lastError()

                if (failure.equals("")) {

                    if (part.length > remaining) {
                        failure = (
                                format(
                                        "input exceeds configured byte limit ({})",
                                maximumBytes))
                        limitExceeded = true
                    }
                    else {
                        int64 index = 0
                        while (index < part.length) {
                            bytes.append(part[index])
                            index = index + 1
                        }
                        finished = file.eof()
                        if (!finished && part.length == 0) {
                            failure = "read made no progress"
                        }
                    }

                }

            }

        }
        finally {
            file.close()
            String closeError = Sys.System().lastError()
            if (failure.equals("") && !closeError.equals("")) {
                failure = closeError
            }
        }
        if (!failure.equals("")) {
            int64 category = Result.IO_ERROR
            if (limitExceeded) {
                category = Result.LIMIT_EXCEEDED
            }
            return(Result(
                    buffer[],
                    format("read '{}': {}", path, failure),
                    category))
        }
        return(Result(bytes, "", Result.OK))
    }

    /*
     * Compute write for this Files. Parameters: path is a String; bytes is a
     * buffer. It returns Result.
     */
    Result Files.write(String path, buffer bytes) {
        if (bytes == null) {
            return(Result(buffer[], "write requires a byte buffer"))
        }
        Sys.File file = null
        try {
            file = Sys.File(path, "wb")
        }
        except(Exception) as error {
            return(Result(buffer[], error.message))
        }
        String failure = ""
        try {

            int64 offset = 0
            while (offset < bytes.length && failure.equals("")) {
                int64 end = offset + 65536
                if (end > bytes.length) {
                    end = bytes.length
                }
                int64 count = file.writeBytes(bytes[offset:end])
                failure = Sys.System().lastError()
                if (failure.equals("")) {
                    if (count <= 0 || count > end - offset) {
                        failure = "invalid write progress"
                    }
                    else {
                        offset = offset + count
                    }
                }
            }

        }
        finally {
            file.close()
            String closeError = Sys.System().lastError()
            if (failure.equals("") && !closeError.equals("")) {
                failure = closeError
            }
        }
        if (!failure.equals("")) {
            return(
                    Result(
                    buffer[],
                    format("write '{}': {}", path, failure)))
        }
        return(Result(buffer[], ""))
    }

}
