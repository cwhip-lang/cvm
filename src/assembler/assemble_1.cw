/*
 * src/assembler/assemble_1.cw — Out-of-line Assembler methods, part 1.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Construct an Assembler and store its initial fields (functions, globals,
 * arrays, functionNames, globalNames, arrayNames, current, entry, entryLine,
 * version, literals, schema). It takes no parameters. It constructs an
 * Assembler.
 */
Assembler Assembler.Assembler() {
    functions = []
    globals = []
    arrays = []
    functionNames = []
    globalNames = []
    arrayNames = []
    current = null
    entry = ""
    entryLine = 1
    version = false
    literals = Literals()
    schema = CVM.Opcode()
}

/*
 * Perform fail on this Assembler. It raises on failure. Parameters: message is
 * a String; row is an int64; col is an int64. It does not return a value.
 */
void Assembler.fail(String message, int64 row, int64 col) {
    raise(AssemblyError(message, row, col))
}

/*
 * Compute find for this Assembler. Parameters: symbols is a list; name is a
 * String. It returns int64.
 */
int64 Assembler.find(list symbols, String name) {
    int64 index = 0
    while (index < symbols.length) {
        Symbol symbol = symbols[index] as Symbol
        if (symbol.name.equals(name)) {
            return(symbol.value)
        }
        index = index + 1
    }
    return(-1)
}

/*
 * Perform declare on this Assembler. Parameters: symbols is a list; name is a
 * String; value is an int64; row is an int64; col is an int64. It does not
 * return a value.
 */
void Assembler.declare(list symbols, String name, int64 value, int64 row,
        int64 col) {
    if (!literals.identifier(name)) {
        fail("invalid identifier", row, col)
    }
    if (find(symbols, name) >= 0) {
        fail(format("duplicate symbol '{}'", name), row, col)
    }
    symbols.append(Symbol(name, value))
}

/*
 * Perform local on this Assembler. Parameters: name is a String; valueType is
 * an int64; row is an int64; col is an int64. It does not return a value.
 */
void Assembler.local(String name, int64 valueType, int64 row, int64 col) {
    if (current.started) {
        fail("local declarations must precede statements", row, col)
    }
    if (current.types.length >= 65536) {
        fail("too many parameters and locals", row, col)
    }
    declare(current.locals, name, current.types.length, row, col)
    current.types.append(valueType)
}

/*
 * Perform array declaration on this Assembler. Parameters: node is an AstNode;
 * source is a SourceLine. It does not return a value.
 */
void Assembler.arrayDeclaration(AstNode node, SourceLine source) {
    int64 row = source.row
    int64 col = source.column(node)
    String name = node.childAt(1).lexeme()
    int64 element = (
            literals.valueType(node.childAt(3).lexeme(), false, row,
            source.column(node.childAt(3))))
    if (element == 3) {
        fail("arrays require i32 or u8 elements", row, col)
    }
    int64 count = (
            literals.number(node.childAt(5).lexeme(), row,
            source.column(node.childAt(5))))
    if (count <= 0 || count > 4294967295) {
        fail("array capacity out of range", row, col)
    }
    if (arrays.length >= 65536) {
        fail("too many arrays", row, col)
    }
    int64 owner = 65535
    if (current != null) {
        if (current.started) {
            fail("local declarations must precede statements", row, col)
        }
        owner = functions.length - 1
    }
    declare(arrayNames, name, arrays.length, row,
            source.column(node.childAt(
            1)))

    buffer data = buffer[]
    if (node.childCount() > 7) {
        int64 elementWidth = 1
        if (element == 1) {
            elementWidth = 4
        }
        if (count > 4294967295 / elementWidth) {
            fail("array initializer byte length exceeds v1 range", row,
                    col)
        }

        AstNode initializer = node.childAt(8)
        CVM.ByteWriter writer = CVM.ByteWriter()
        if (initializer.childAt(0).kind().equals("STRING")) {
            if (element != 2) {
                fail("string initializer requires u8 array", row, col)
            }
            data = source.quoted(initializer.childAt(0), literals)
            data.append(0)
            if (data.length > count) {
                fail(
                        "string initializer exceeds capacity including NUL",
                        row,
                        col)
            }
        }
        else {

            int64 index = 1
            int64 used = 0
            while (index < initializer.childCount() - 1) {
                if (used >= count) {
                    fail("array initializer exceeds capacity", row,
                            source.column(initializer.childAt(
                            index)))
                }
                int64 value = (
                        source.scalar(initializer.childAt(index), element,
                        literals))
                if (element == 1) {
                    writer.writeI32(value)
                }
                else {
                    writer.writeU8(value)
                }
                used = used + 1
                index = index + 2
            }

            data = writer.bytes()
        }

        int64 width = 1
        if (element == 1) {
            width = 4
        }
        while (data.length < count * width) {
            data.append(0)
        }
    }

    arrays.append(ArrayDeclaration(name, owner, element, count, data))
}
