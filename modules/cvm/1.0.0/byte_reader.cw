/*
 * modules/cvm/1.0.0/byte_reader.cw — Read a little-endian buffer. The first
 * truncated read sticks, and later reads return zero.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Read a little-endian buffer. The first truncated read sticks, and later
     * reads return zero.
     */
    class ByteReader {
        private:
        buffer _bytes
        int64 _offset
        int64 _error
        int64 _errorOffset

        public:
        enum {
            OK = 0, TRUNCATED = 1
        }

        ByteReader(buffer bytes)

        void seek(int64 offset)

        int64 readU8()

        int64 readU16()

        int64 readU32()

        int64 readI32()

        int64 offset()

        int64 errorCode()

        int64 errorOffset()

    }

    /*
     * Construct a ByteReader and store its initial fields (_bytes, _offset,
     * _error, _errorOffset). Parameters: bytes is a buffer. It constructs a
     * ByteReader.
     */
    ByteReader ByteReader.ByteReader(buffer bytes) {
        _bytes = bytes
        _offset = 0
        _error = OK
        _errorOffset = -1
    }

    /*
     * Perform seek on this ByteReader. Parameters: offset is an int64. It does
     * not return a value.
     */
    void ByteReader.seek(int64 offset) {
        if (_error != OK) {
            return
        }
        if (offset < 0 || offset > _bytes.length) {
            _error = TRUNCATED
            _errorOffset = _offset
            return()
        }
        _offset = offset
    }

    /*
     * Compute read u8 for this ByteReader. It takes no parameters. It returns
     * int64.
     */
    int64 ByteReader.readU8() {
        if (_error != OK) {
            return(0)
        }
        if (_offset < 0 || _offset >= _bytes.length) {
            _error = TRUNCATED
            _errorOffset = _offset
            return(0)
        }
        int64 value = int64(_bytes[_offset])
        _offset = _offset + 1
        return(value)
    }

    /*
     * Compute read u16 for this ByteReader. It takes no parameters. It returns
     * int64.
     */
    int64 ByteReader.readU16() {
        if (_error != OK) {
            return(0)
        }
        if (_offset < 0 || _bytes.length - _offset < 2) {
            _error = TRUNCATED
            _errorOffset = _offset
            return(0)
        }
        int64 value = (
                int64(_bytes[_offset]) + int64(_bytes[_offset + 1]) * 256)
        _offset = _offset + 2
        return(value)
    }

    /*
     * Compute read u32 for this ByteReader. It takes no parameters. It returns
     * int64.
     */
    int64 ByteReader.readU32() {
        if (_error != OK) {
            return(0)
        }
        if (_offset < 0 || _bytes.length - _offset < 4) {
            _error = TRUNCATED
            _errorOffset = _offset
            return(0)
        }
        int64 value = (
                int64(_bytes[_offset]) + int64(_bytes[_offset + 1]) * 256
                + int64(_bytes[_offset + 2]) * 65536 + int64(_bytes[_offset
                + 3]) * 16777216)
        _offset = _offset + 4
        return(value)
    }

    /*
     * Compute read i32 for this ByteReader. It takes no parameters. It returns
     * int64.
     */
    int64 ByteReader.readI32() {
        int64 value = readU32()
        if (_error != OK) {
            return(0)
        }
        if (value >= 2147483648) {
            return(value - 4294967296)
        }
        return(value)
    }

    /*
     * Report offset for this ByteReader. The result is _offset. It takes no
     * parameters. It returns int64.
     */
    int64 ByteReader.offset() {
        return(_offset)
    }

    /*
     * Report error code for this ByteReader. The result is _error. It takes no
     * parameters. It returns int64.
     */
    int64 ByteReader.errorCode() {
        return(_error)
    }

    /*
     * Report error offset for this ByteReader. The result is _errorOffset. It
     * takes no parameters. It returns int64.
     */
    int64 ByteReader.errorOffset() {
        return(_errorOffset)
    }
}
