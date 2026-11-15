/*
 * modules/cvm/1.0.0/section.cw — Own one directory record: kind, flags,
 * count, payload, and the file extent assigned while encoding.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Own one directory record: kind, flags, count, payload, and the file
     * extent assigned while encoding.
     */
    class Section {
        private:
        int64 _kind
        int64 _flags
        int64 _count
        buffer _bytes
        int64 _offset
        int64 _length

        public:
        Section(int64 kind, int64 flags, int64 count, buffer bytes)

        int64 kind()

        int64 flags()

        int64 count()

        buffer bytes()

        int64 offset()

        int64 length()

        void setExtent(int64 offset, int64 length)

    }

    /*
     * Construct a Section and store its initial fields (_kind, _flags, _count,
     * _bytes, _offset, _length). Parameters: kind is an int64; flags is an
     * int64; count is an int64; bytes is a buffer. It constructs a Section.
     */
    Section Section.Section(int64 kind, int64 flags, int64 count, buffer bytes)
    {
        _kind = kind
        _flags = flags
        _count = count
        _bytes = bytes
        _offset = 0
        _length = bytes.length
    }

    /*
     * Report kind for this Section. The result is _kind. It takes no
     * parameters. It returns int64.
     */
    int64 Section.kind() {
        return(_kind)
    }

    /*
     * Report flags for this Section. The result is _flags. It takes no
     * parameters. It returns int64.
     */
    int64 Section.flags() {
        return(_flags)
    }

    /*
     * Report count for this Section. The result is _count. It takes no
     * parameters. It returns int64.
     */
    int64 Section.count() {
        return(_count)
    }

    /*
     * Report bytes for this Section. The result is _bytes. It takes no
     * parameters. It returns buffer.
     */
    buffer Section.bytes() {
        return(_bytes)
    }

    /*
     * Report offset for this Section. The result is _offset. It takes no
     * parameters. It returns int64.
     */
    int64 Section.offset() {
        return(_offset)
    }

    /*
     * Report length for this Section. The result is _length. It takes no
     * parameters. It returns int64.
     */
    int64 Section.length() {
        return(_length)
    }

    /*
     * Perform set extent on this Section. Parameters: offset is an int64;
     * length is an int64. It does not return a value.
     */
    void Section.setExtent(int64 offset, int64 length) {
        _offset = offset
        _length = length
    }
}
