/*
 * modules/cvm/1.0.0/opcode_2.cw — Out-of-line Opcode methods, part 2.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Compute operation for this Opcode. Parameters: opcode is an int64. It
     * returns String.
     */
    String Opcode.operation(int64 opcode) {
        if (opcode == NOP) {
            return("no effect")
        }
        if (opcode == CONST_I32) {
            return("signed constant")
        }
        if (opcode == CONST_U8) {
            return("unsigned constant")
        }
        if (opcode == LDLOC || opcode == LDGLOBAL) {
            return("load typed value")
        }
        if (opcode == STLOC || opcode == STGLOBAL) {
            return("store typed value and leave it")
        }
        if (opcode == ARRAY) {
            return("reference a global or current-function array")
        }
        if (opcode == ALEN) {
            return("array element count")
        }
        if (opcode == AGET) {
            return("checked indexed load")
        }
        if (opcode == ASET) {
            return("checked indexed store and leave value")
        }
        if (opcode == ADD_I32) {
            return("checked left plus right")
        }
        if (opcode == SUB_I32) {
            return("checked left minus right")
        }
        if (opcode == MUL_I32) {
            return("checked multiply")
        }
        if (opcode == DIV_I32) {
            return("checked signed divide")
        }
        if (opcode == REM_I32) {
            return("checked signed remainder")
        }
        if (opcode == NEG_I32) {
            return("checked negation")
        }
        if (opcode == EQ_I32) {
            return("equal, result 0 or 1")
        }
        if (opcode == NE_I32) {
            return("not equal, result 0 or 1")
        }
        if (opcode == LT_I32) {
            return("signed less-than, result 0 or 1")
        }
        if (opcode == LE_I32) {
            return("signed less-than-or-equal, result 0 or 1")
        }
        if (opcode == GT_I32) {
            return("signed greater-than, result 0 or 1")
        }
        if (opcode == GE_I32) {
            return("signed greater-than-or-equal, result 0 or 1")
        }
        if (opcode == TO_U8) {
            return("checked conversion to 0..255")
        }
        if (opcode == TO_I32) {
            return("zero-extend u8 to i32")
        }
        if (opcode == DUP) {
            return("duplicate scalar or file value, not ArrayRef")
        }
        if (opcode == POP) {
            return("discard scalar or file value")
        }
        if (opcode == JMP) {
            return("branch to function-relative byte target")
        }
        if (opcode == JZ) {
            return("pop i32 and branch if zero")
        }
        if (opcode == CALL) {
            return("call indexed function")
        }
        if (opcode == RET) {
            return("return void")
        }
        if (opcode == RET_I32) {
            return("return i32")
        }
        if (opcode == RET_U8) {
            return("return u8")
        }
        if (opcode == SYS) {
            return("invoke synchronous host service")
        }
        if (opcode == RET_FILE) {
            return("return file handle")
        }
        return("")
    }
}
