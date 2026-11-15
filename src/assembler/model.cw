/*
 * src/assembler/model.cw — Data carried through assembly: errors, symbols,
 * instructions, functions, arrays, and globals.
 *
 * Created: 2026-10-22
 * Author: Charles Tilbury
 *
 * Changelog:
 *   2026-10-22  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import cvm as CVM

/*
 * Carry an assembly diagnostic with the source line and column that should be
 * reported.
 */
class AssemblyError : public Exception {
    public:
    int64 column
    int64 line
    AssemblyError(String message, int64 row, int64 col)

}

/*
 * Construct an AssemblyError and store its initial fields (line, column).
 * Parameters: message is a String; row is an int64; col is an int64. It
 * constructs an AssemblyError.
 */
AssemblyError AssemblyError.AssemblyError(String message, int64 row, int64 col)
{
    super Exception(message)
    line = row
    column = col
}

/*
 * Own one assembly name and the integer value the assembler assigned to it.
 */
class Symbol {
    public:
    String name
    int64 value
    Symbol(String n, int64 v)

}

/*
 * Construct a Symbol and store its initial fields (name, value). Parameters: n
 * is a String; v is an int64. It constructs a Symbol.
 */
Symbol Symbol.Symbol(String n, int64 v) {
    name = n
    value = v
}

/*
 * Own one parsed instruction, its source location, its byte offset, and its
 * resolved operand.
 */
class Instruction {
    public:
    int64 opcode
    String operand
    int64 line
    int64 column
    int64 offset
    int64 value
    Instruction(int64 op, String arg, int64 row, int64 col, int64 at)

}

/*
 * Construct an Instruction and store its initial fields (opcode, operand,
 * line, column, offset, value). Parameters: op is an int64; arg is a String;
 * row is an int64; col is an int64; at is an int64. It constructs an
 * Instruction.
 */
Instruction Instruction.Instruction(int64 op, String arg, int64 row, int64 col,
        int64 at)
{
    opcode = op
    operand = arg
    line = row
    column = col
    offset = at
    value = 0
}

/*
 * Own one function while it is being assembled: locals, labels, instructions,
 * and the declared result.
 */
class Function {
    public:
    String name
    list locals
    buffer types
    list labels
    list instructions
    int64 parameters
    int64 result
    int64 length
    int64 line
    bool started
    Function(String n, int64 r, int64 row)

}

/*
 * Construct a Function and store its initial fields (name, result, line,
 * locals, types, labels, instructions, parameters, length, started).
 * Parameters: n is a String; r is an int64; row is an int64. It constructs a
 * Function.
 */
Function Function.Function(String n, int64 r, int64 row) {
    name = n
    result = r
    line = row
    locals = []
    types = buffer[]
    labels = []
    instructions = []
    parameters = 0
    length = 0
    started = false
}

/*
 * Own one array declaration, its owner function, element type, capacity, and
 * initializer bytes.
 */
class ArrayDeclaration {
    public:
    String name
    int64 owner
    int64 element
    int64 count
    buffer data
    ArrayDeclaration(String n, int64 o, int64 e, int64 c, buffer d)

}

/*
 * Construct an ArrayDeclaration and store its initial fields (name, owner,
 * element, count, data). Parameters: n is a String; o is an int64; e is an
 * int64; c is an int64; d is a buffer. It constructs an ArrayDeclaration.
 */
ArrayDeclaration ArrayDeclaration.ArrayDeclaration(String n, int64 o, int64 e,
        int64 c, buffer d)
{
    name = n
    owner = o
    element = e
    count = c
    data = d
}

/*
 * Own one global name, its type code, and its initial value.
 */
class GlobalDeclaration {
    public:
    String name
    int64 valueType
    int64 value
    GlobalDeclaration(String n, int64 t, int64 v)

}

/*
 * Construct a GlobalDeclaration and store its initial fields (name, valueType,
 * value). Parameters: n is a String; t is an int64; v is an int64. It
 * constructs a GlobalDeclaration.
 */
GlobalDeclaration GlobalDeclaration.GlobalDeclaration(String n, int64 t,
        int64 v)
{
    name = n
    valueType = t
    value = v
}

