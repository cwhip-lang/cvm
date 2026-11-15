/*
 * modules/cvm/1.0.0/opcode_1.cw — Out-of-line Opcode methods, part 1.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Report is valid for this Opcode. The result is opcode >= NOP && opcode
     * <= RET_FILE. Parameters: opcode is an int64. It returns bool.
     */
    bool Opcode.isValid(int64 opcode) {
        return(opcode >= NOP && opcode <= RET_FILE)
    }

    /*
     * Compute operand width for this Opcode. Parameters: opcode is an int64.
     * It returns int64.
     */
    int64 Opcode.operandWidth(int64 opcode) {
        if (opcode == CONST_I32 || opcode == JMP || opcode == JZ) {
            return(4)
        }
        if (opcode == LDLOC || opcode == STLOC || opcode == LDGLOBAL
                || opcode == STGLOBAL || opcode == ARRAY || opcode
                == CALL) {
            return(2)
        }
        if (opcode == CONST_U8 || opcode == SYS) {
            return(1)
        }
        return(0)
    }

    /*
     * Compute operand kind for this Opcode. Parameters: opcode is an int64. It
     * returns int64.
     */
    int64 Opcode.operandKind(int64 opcode) {
        if (opcode == CONST_I32) {
            return(1)
        }
        if (opcode == CONST_U8 || opcode == SYS) {
            return(2)
        }
        if (opcode == LDLOC || opcode == STLOC) {
            return(3)
        }
        if (opcode == LDGLOBAL || opcode == STGLOBAL) {
            return(4)
        }
        if (opcode == ARRAY) {
            return(5)
        }
        if (opcode == JMP || opcode == JZ) {
            return(6)
        }
        if (opcode == CALL) {
            return(7)
        }
        return(0)
    }

    /*
     * Compute mnemonic for this Opcode. Parameters: opcode is an int64. It
     * returns String.
     */
    String Opcode.mnemonic(int64 opcode) {
        if (opcode == NOP) {
            return("nop")
        }
        if (opcode == CONST_I32) {
            return("const.i32")
        }
        if (opcode == CONST_U8) {
            return("const.u8")
        }
        if (opcode == LDLOC) {
            return("ldloc")
        }
        if (opcode == STLOC) {
            return("stloc")
        }
        if (opcode == LDGLOBAL) {
            return("ldglobal")
        }
        if (opcode == STGLOBAL) {
            return("stglobal")
        }
        if (opcode == ARRAY) {
            return("array")
        }
        if (opcode == ALEN) {
            return("alen")
        }
        if (opcode == AGET) {
            return("aget")
        }
        if (opcode == ASET) {
            return("aset")
        }
        if (opcode == ADD_I32) {
            return("add.i32")
        }
        if (opcode == SUB_I32) {
            return("sub.i32")
        }
        if (opcode == MUL_I32) {
            return("mul.i32")
        }
        if (opcode == DIV_I32) {
            return("div.i32")
        }
        if (opcode == REM_I32) {
            return("rem.i32")
        }
        if (opcode == NEG_I32) {
            return("neg.i32")
        }
        if (opcode == EQ_I32) {
            return("eq.i32")
        }
        if (opcode == NE_I32) {
            return("ne.i32")
        }
        if (opcode == LT_I32) {
            return("lt.i32")
        }
        if (opcode == LE_I32) {
            return("le.i32")
        }
        if (opcode == GT_I32) {
            return("gt.i32")
        }
        if (opcode == GE_I32) {
            return("ge.i32")
        }
        if (opcode == TO_U8) {
            return("to.u8")
        }
        if (opcode == TO_I32) {
            return("to.i32")
        }
        if (opcode == DUP) {
            return("dup")
        }
        if (opcode == POP) {
            return("pop")
        }
        if (opcode == JMP) {
            return("jmp")
        }
        if (opcode == JZ) {
            return("jz")
        }
        if (opcode == CALL) {
            return("call")
        }
        if (opcode == RET) {
            return("ret")
        }
        if (opcode == RET_I32) {
            return("ret.i32")
        }
        if (opcode == RET_U8) {
            return("ret.u8")
        }
        if (opcode == SYS) {
            return("sys")
        }
        if (opcode == RET_FILE) {
            return("ret.file")
        }
        return("")
    }

    /*
     * Compute operand schema for this Opcode. Parameters: opcode is an int64.
     * It returns String.
     */
    String Opcode.operandSchema(int64 opcode) {
        if (opcode == CONST_I32) {
            return("i32")
        }
        if (opcode == CONST_U8) {
            return("u8 value")
        }
        if (opcode == SYS) {
            return("u8 service number (0..12)")
        }
        if (opcode == LDLOC || opcode == STLOC) {
            return("u16 local index")
        }
        if (opcode == LDGLOBAL || opcode == STGLOBAL) {
            return("u16 global index")
        }
        if (opcode == ARRAY) {
            return("u16 array index")
        }
        if (opcode == JMP || opcode == JZ) {
            return("u32 function-relative target")
        }
        if (opcode == CALL) {
            return("u16 function index")
        }
        if (isValid(opcode)) {
            return("none")
        }
        return("")
    }

    /*
     * Compute stack effect for this Opcode. Parameters: opcode is an int64. It
     * returns String.
     */
    String Opcode.stackEffect(int64 opcode) {
        if (opcode == NOP) {
            return("S -> S")
        }
        if (opcode == CONST_I32) {
            return("S -> S,i32")
        }
        if (opcode == CONST_U8) {
            return("S -> S,u8")
        }
        if (opcode == LDLOC || opcode == LDGLOBAL) {
            return("S -> S,T")
        }
        if (opcode == STLOC || opcode == STGLOBAL) {
            return("S,T -> S,T")
        }
        if (opcode == ARRAY) {
            return("S -> S,Array<T>")
        }
        if (opcode == ALEN) {
            return("S,Array<T> -> S,i32")
        }
        if (opcode == AGET) {
            return("S,Array<T>,i32 -> S,T")
        }
        if (opcode == ASET) {
            return("S,Array<T>,i32,T -> S,T")
        }
        if (opcode == ADD_I32 || opcode == SUB_I32 || opcode == MUL_I32
                || opcode == DIV_I32 || opcode == REM_I32 || opcode
                == EQ_I32 || opcode == NE_I32 || opcode == LT_I32 || opcode
                == LE_I32 || opcode == GT_I32 || opcode == GE_I32) {
            return("S,i32,i32 -> S,i32")
        }
        if (opcode == NEG_I32 || opcode == TO_U8 || opcode == TO_I32) {
            return("S,T -> S,T")
        }
        if (opcode == DUP) {
            return("S,T -> S,T,T")
        }
        if (opcode == POP) {
            return("S,T -> S")
        }
        if (opcode == JMP) {
            return("S -> S")
        }
        if (opcode == JZ) {
            return("S,i32 -> S")
        }
        if (opcode == CALL) {
            return("signature-dependent")
        }
        if (opcode == RET) {
            return("S -> return")
        }
        if (opcode == RET_I32 || opcode == RET_U8 || opcode == RET_FILE) {
            return("S,T -> return")
        }
        if (opcode == SYS) {
            return("service-dependent")
        }
        return("")
    }
}
