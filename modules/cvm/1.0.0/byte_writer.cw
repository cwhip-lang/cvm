/*
 * modules/cvm/1.0.0/byte_writer.cw — Own a little-endian byte buffer. A
 * range error sticks and later writes do not change the buffer.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Own a little-endian byte buffer. A range error sticks and later writes
     * do not change the buffer.
     */
    class ByteWriter {
        private:
        buffer _bytes
        int64 _error

        public:
        enum {
            OK = 0, RANGE_ERROR = 1
        }

        ByteWriter()

        bool writeU8(int64 value)

        bool writeU16(int64 value)

        bool writeU32(uint64 value)

        bool writeI32(int64 value)

        int64 errorCode()

        buffer bytes()

    }

    /*
     * Construct a ByteWriter and store its initial fields (_bytes, _error). It
     * takes no parameters. It constructs a ByteWriter.
     */
    ByteWriter ByteWriter.ByteWriter() {
        _bytes = buffer[]
        _error = OK
    }

    /*
     * Report whether this ByteWriter write u8. Parameters: value is an int64.
     * It returns bool.
     */
    bool ByteWriter.writeU8(int64 value) {
        if (_error != OK) {
            return(false)
        }
        if (value < 0 || value > 255) {
            _error = RANGE_ERROR
            return(false)
        }
        _bytes.append(value)
        return(true)
    }

    /*
     * Report whether this ByteWriter write u16. Parameters: value is an int64.
     * It returns bool.
     */
    bool ByteWriter.writeU16(int64 value) {
        if (_error != OK) {
            return(false)
        }
        if (value < 0 || value > 65535) {
            _error = RANGE_ERROR
            return(false)
        }
        _bytes.append(value % 256)
        _bytes.append((value / 256) % 256)
        return(true)
    }

    /*
     * Report whether this ByteWriter write u32. Parameters: value is an
     * uint64. It returns bool.
     */
    bool ByteWriter.writeU32(uint64 value) {
        if (_error != OK) {
            return(false)
        }
        if (value > 4294967295u) {
            _error = RANGE_ERROR
            return(false)
        }
        _bytes.append(value % 256u)
        _bytes.append((value / 256u) % 256u)
        _bytes.append((value / 65536u) % 256u)
        _bytes.append((value / 16777216u) % 256u)
        return(true)
    }

    /*
     * Report whether this ByteWriter write i32. Parameters: value is an int64.
     * It returns bool.
     */
    bool ByteWriter.writeI32(int64 value) {
        if (_error != OK) {
            return(false)
        }
        if (value < -2147483648 || value > 2147483647) {
            _error = RANGE_ERROR
            return(false)
        }
        if (value < 0) {
            return(writeU32(uint64(value + 4294967296)))
        }
        return(writeU32(uint64(value)))
    }

    /*
     * Report error code for this ByteWriter. The result is _error. It takes no
     * parameters. It returns int64.
     */
    int64 ByteWriter.errorCode() {
        return(_error)
    }

    /*
     * Report bytes for this ByteWriter. The result is _bytes. It takes no
     * parameters. It returns buffer.
     */
    buffer ByteWriter.bytes() {
        return(_bytes)
    }
}
