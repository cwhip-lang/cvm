/*
 * modules/cvm/1.0.0/format.cw — Publish the v1 header, directory, section,
 * and fixed-record sizes used by every container.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Publish the v1 header, directory, section, and fixed-record sizes used
     * by every container.
     */
    class Format {
        public:
        enum {
            HEADER_SIZE = 32,
            DIRECTORY_ENTRY_SIZE = 16,
            MAJOR_VERSION = 1,
            MINOR_VERSION = 0,
            CODE = 1,
            FUNCS = 2,
            TYPES = 3,
            GLOBALS = 4,
            ARRAYS = 5,
            DATA = 6,
            STRINGS = 7,
            DEBUG = 8,
            FUNCTION_SIZE = 28,
            GLOBAL_SIZE = 12,
            ARRAY_SIZE = 20,
            DEBUG_SIZE = 20
        }
    }
}
