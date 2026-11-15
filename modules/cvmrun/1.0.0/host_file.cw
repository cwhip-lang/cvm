/*
 * modules/cvmrun/1.0.0/host_file.cw — Own one host file opened for the
 * guest. invalidate drops the live SDK file.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Own one host file opened for the guest. invalidate drops the live SDK
     * file.
     */
    class HostFile {
        private:
        int64 _id
        Sys.File _file
        bool _open
        bool _integerHandle

        public:
        HostFile(int64 id, Sys.File file, bool integerHandle)

        int64 id()

        Sys.File file()

        bool open()

        bool integerHandle()

        void invalidate()

    }

    /*
     * Construct a HostFile and store its initial fields (_id, _file, _open,
     * _integerHandle). Parameters: id is an int64; file is a Sys.File;
     * integerHandle is a bool. It constructs a HostFile.
     */
    HostFile HostFile.HostFile(int64 id, Sys.File file, bool integerHandle) {
        _id = id
        _file = file
        _open = true
        _integerHandle = integerHandle
    }

    /*
     * Report id for this HostFile. The result is _id. It takes no parameters.
     * It returns int64.
     */
    int64 HostFile.id() {
        return(_id)
    }

    /*
     * Report file for this HostFile. The result is _file. It takes no
     * parameters. It returns Sys.File.
     */
    Sys.File HostFile.file() {
        return(_file)
    }

    /*
     * Report open for this HostFile. The result is _open. It takes no
     * parameters. It returns bool.
     */
    bool HostFile.open() {
        return(_open)
    }

    /*
     * Report integer handle for this HostFile. The result is _integerHandle.
     * It takes no parameters. It returns bool.
     */
    bool HostFile.integerHandle() {
        return(_integerHandle)
    }

    /*
     * Perform invalidate on this HostFile. It takes no parameters. It does not
     * return a value.
     */
    void HostFile.invalidate() {
        _open = false
    }
}
