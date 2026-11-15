/*
 * src/assembler/assemble.cw — Turn one assembly translation unit into a
 * validated v1 container.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Turn one assembly translation unit into a validated v1 container.
 */
class Assembler {
    public:
    list functions
    list globals
    list arrays
    list functionNames
    list globalNames
    list arrayNames
    Function current
    String entry
    int64 entryLine
    bool version
    Literals literals
    CVM.Opcode schema

    Assembler()

    void fail(String message, int64 row, int64 col)

    int64 find(list symbols, String name)

    void declare(list symbols, String name, int64 value, int64 row,
            int64 col)

    void local(String name, int64 valueType, int64 row, int64 col)

    void arrayDeclaration(AstNode node, SourceLine source)

    void consume(AstNode node, SourceLine source)

    int64 resolve(list names, String name, Instruction instruction)

    buffer encode(buffer text)

}
