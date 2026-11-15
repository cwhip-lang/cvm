/*
 * modules/cvm/1.0.0/opcode.cw — Publish the v1 opcode numbers and the
 * queries that describe their operands, stack effect, and operation.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Publish the v1 opcode numbers and the queries that describe their
     * operands, stack effect, and operation.
     */
    class Opcode {
        public:
        enum {
            NOP = 0x00, CONST_I32 = 0x01, CONST_U8 = 0x02,
            LDLOC = 0x03, STLOC = 0x04, LDGLOBAL = 0x05,
            STGLOBAL = 0x06, ARRAY = 0x07, ALEN = 0x08,
            AGET = 0x09, ASET = 0x0a, ADD_I32 = 0x0b,
            SUB_I32 = 0x0c, MUL_I32 = 0x0d, DIV_I32 = 0x0e,
            REM_I32 = 0x0f, NEG_I32 = 0x10, EQ_I32 = 0x11,
            NE_I32 = 0x12, LT_I32 = 0x13, LE_I32 = 0x14,
            GT_I32 = 0x15, GE_I32 = 0x16, TO_U8 = 0x17,
            TO_I32 = 0x18, DUP = 0x19, POP = 0x1a,
            JMP = 0x1b, JZ = 0x1c, CALL = 0x1d, RET = 0x1e,
            RET_I32 = 0x1f, RET_U8 = 0x20, SYS = 0x21,
            RET_FILE = 0x22
        }

        bool isValid(int64 opcode)

        int64 operandWidth(int64 opcode)

        int64 operandKind(int64 opcode)

        String mnemonic(int64 opcode)

        String operandSchema(int64 opcode)

        String stackEffect(int64 opcode)

        String operation(int64 opcode)

    }
}
