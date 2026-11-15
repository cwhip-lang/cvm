/*
 * modules/cvmrun/1.0.0/capabilities.cw — Own the host switches for stdin,
 * stdout, the guest file API, and the open-file budget.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Own the host switches for stdin, stdout, the guest file API, and the
     * open-file budget.
     */
    class Capabilities {
        private:
        bool _stdin
        bool _stdout
        bool _files
        int64 _maxOpenFiles

        public:
        enum {
            DEFAULT_MAX_OPEN_FILES = 64, MAX_OPEN_FILES = 4096
        }

        Capabilities()

        Capabilities(
                bool stdinEnabled,
                bool stdoutEnabled,
                bool filesEnabled,
                     int64 maxOpenFiles)

        bool valid()

        bool stdinEnabled()

        bool stdoutEnabled()

        bool filesEnabled()

        int64 maxOpenFiles()

    }

    /*
     * Construct a Capabilities and store its initial fields (_stdin, _stdout,
     * _files, _maxOpenFiles). It takes no parameters. It constructs a
     * Capabilities.
     */
    Capabilities Capabilities.Capabilities() {
        _stdin = true
        _stdout = true
        _files = true
        _maxOpenFiles = DEFAULT_MAX_OPEN_FILES
    }

    /*
     * Construct a Capabilities and store its initial fields (_stdin, _stdout,
     * _files, _maxOpenFiles). Parameters: stdinEnabled is a bool;
     * stdoutEnabled is a bool; filesEnabled is a bool; maxOpenFiles is an
     * int64. It constructs a Capabilities.
     */
    Capabilities Capabilities.Capabilities(
            bool stdinEnabled,
            bool stdoutEnabled,
            bool filesEnabled,
                 int64 maxOpenFiles) {
        _stdin = stdinEnabled
        _stdout = stdoutEnabled
        _files = filesEnabled
        _maxOpenFiles = maxOpenFiles
    }

    /*
     * Report valid for this Capabilities. The result is _maxOpenFiles >= 0 &&
     * _maxOpenFiles <= MAX_OPEN_FILES. It takes no parameters. It returns
     * bool.
     */
    bool Capabilities.valid() {
        return(_maxOpenFiles >= 0 && _maxOpenFiles <= MAX_OPEN_FILES)
    }

    /*
     * Report stdin enabled for this Capabilities. The result is _stdin. It
     * takes no parameters. It returns bool.
     */
    bool Capabilities.stdinEnabled() {
        return(_stdin)
    }

    /*
     * Report stdout enabled for this Capabilities. The result is _stdout. It
     * takes no parameters. It returns bool.
     */
    bool Capabilities.stdoutEnabled() {
        return(_stdout)
    }

    /*
     * Report files enabled for this Capabilities. The result is _files. It
     * takes no parameters. It returns bool.
     */
    bool Capabilities.filesEnabled() {
        return(_files)
    }

    /*
     * Report max open files for this Capabilities. The result is
     * _maxOpenFiles. It takes no parameters. It returns int64.
     */
    int64 Capabilities.maxOpenFiles() {
        return(_maxOpenFiles)
    }
}
