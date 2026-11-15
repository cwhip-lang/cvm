/*
 * modules/cvm/1.0.0/service.cw — Publish the v1 host-service ids, assembly
 * names, and parameter and result counts.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Publish the v1 host-service ids, assembly names, and parameter and
     * result counts.
     */
    class Service {
        public:
        enum {
            STDOUT_I32 = 0, STDOUT_BYTE = 1, STDOUT_WRITE = 2,
            STDIN_BYTE = 3, FILE_OPEN_READ = 4, FILE_OPEN_WRITE = 5,
            FILE_READ = 6, FILE_WRITE = 7, FILE_CLOSE = 8,
            FILE_OPEN = 9, FILE_READ_HANDLE = 10, FILE_WRITE_HANDLE = 11,
            FILE_CLOSE_HANDLE = 12
        }

        String name(int64 id)

        int64 parameterCount(int64 id)

        int64 resultCount(int64 id)

    }

    /*
     * Compute name for this Service. Parameters: id is an int64. It returns
     * String.
     */
    String Service.name(int64 id) {
        if (id == STDOUT_I32) {
            return("stdout_i32")
        }
        if (id == STDOUT_BYTE) {
            return("stdout_byte")
        }
        if (id == STDOUT_WRITE) {
            return("stdout_write")
        }
        if (id == STDIN_BYTE) {
            return("stdin_byte")
        }
        if (id == FILE_OPEN_READ) {
            return("file_open_read")
        }
        if (id == FILE_OPEN_WRITE) {
            return("file_open_write")
        }
        if (id == FILE_READ) {
            return("file_read")
        }
        if (id == FILE_WRITE) {
            return("file_write")
        }
        if (id == FILE_CLOSE) {
            return("file_close")
        }
        if (id == FILE_OPEN) {
            return("file_open")
        }
        if (id == FILE_READ_HANDLE) {
            return("file_read_handle")
        }
        if (id == FILE_WRITE_HANDLE) {
            return("file_write_handle")
        }
        if (id == FILE_CLOSE_HANDLE) {
            return("file_close_handle")
        }
        return("")
    }

    /*
     * Compute parameter count for this Service. Parameters: id is an int64. It
     * returns int64.
     */
    int64 Service.parameterCount(int64 id) {
        if (id == STDOUT_WRITE) {
            return(3)
        }
        if (id == FILE_OPEN) {
            return(2)
        }
        if (id == FILE_READ_HANDLE || id == FILE_WRITE_HANDLE) {
            return(3)
        }
        if (id == FILE_CLOSE_HANDLE) {
            return(1)
        }
        if (id == FILE_READ || id == FILE_WRITE) {
            return(4)
        }
        if (id == STDIN_BYTE) {
            return(0)
        }
        if (id >= STDOUT_I32 && id <= FILE_CLOSE) {
            return(1)
        }
        return(-1)
    }

    /*
     * Compute result count for this Service. Parameters: id is an int64. It
     * returns int64.
     */
    int64 Service.resultCount(int64 id) {
        if (id < STDOUT_I32 || id > FILE_CLOSE_HANDLE) {
            return(-1)
        }
        if (id == STDOUT_I32 || id == STDOUT_BYTE || id == FILE_CLOSE ||
            id == FILE_CLOSE_HANDLE) {
            return(0)
        }
        return(1)
    }
}
