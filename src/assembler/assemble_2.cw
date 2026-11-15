/*
 * src/assembler/assemble_2.cw — Out-of-line Assembler methods, part 2.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Perform consume on this Assembler. Parameters: node is an AstNode; source is
 * a SourceLine. It does not return a value.
 */
void Assembler.consume(AstNode node, SourceLine source) {
    String kind = node.kind()
    int64 row = source.row
    int64 col = source.column(node)
    if (!version) {
        if (!kind.equals("version")) {
            fail("file must start with .version 1.0", row, col)
        }
        version = true
        return()
    }
    if (kind.equals("version")) {
        fail("duplicate .version", row, col)
    }

    if (entry.equals("")) {
        if (!kind.equals("entry")) {
            fail("expected .entry main before declarations", row, col)
        }
        entry = node.childAt(1).lexeme()
        entryLine = row
        if (!entry.equals("main")) {
            fail("v1 entry must be main() -> i32", row,
                    source.column(node.childAt(
                    1)))
        }
        return()
    }

    if (kind.equals("entry")) {
        fail("duplicate .entry", row, col)
    }
    if (kind.equals("array_decl")) {
        arrayDeclaration(node, source)
        return }

    if (kind.equals("global_decl")) {
        if (current != null) {
            fail("global declaration inside function", row, col)
        }
        if (globals.length >= 65536) {
            fail("too many globals", row, col)
        }
        String name = node.childAt(1).lexeme()
        int64 valueType = (
                literals.valueType(node.childAt(3).lexeme(), false, row,
                source.column(node.childAt(3))))
        if (valueType == 3) {
            fail("global type must be i32 or u8", row, col)
        }
        int64 value = source.scalar(node.childAt(5), valueType, literals)
        declare(globalNames, name, globals.length, row,
                source.column(node.childAt(
                1)))
        globals.append(GlobalDeclaration(name, valueType, value))
        return()
    }

    if (kind.equals("function_decl")) {
        if (current != null) {
            fail("nested function", row, col)
        }
        if (functions.length >= 65535) {
            fail("too many functions", row, col)
        }
        String name = node.childAt(1).lexeme()
        declare(functionNames, name, functions.length, row,
                source.column(node.childAt(
                1)))
        int64 valueType = (
                literals.valueType(node.childAt(node.childCount()
                - 1).lexeme(), true, row, col))
        current = Function(name, valueType, row)
        functions.append(current)

        int64 index = 3
        while (index < node.childCount() - 3) {
            AstNode parameter = node.childAt(index)
            int64 parameterType = (
                    literals.valueType(parameter.childAt(2).lexeme(),
                    false, row, source.column(parameter.childAt(2))))
            local(parameter.childAt(0).lexeme(), parameterType, row,
                    source.column(
                    parameter))
            current.parameters = current.parameters + 1
            if (current.parameters > 65535) {
                fail("too many parameters", row, col)
            }
            index = index + 2
        }

        return()
    }

    if (current == null) {
        fail("expected declaration outside function", row, col)
    }
    if (kind.equals("end_decl")) {
        if (current.length == 0) {
            fail("function must contain instructions", row, col)
        }
        current = null
        return()
    }
    if (kind.equals("local_decl")) {
        int64 valueType = (
                literals.valueType(node.childAt(3).lexeme(), false, row,
                source.column(node.childAt(3))))
        if (current.types.length - current.parameters >= 65535) {
            fail("too many locals", row, col)
        }
        local(node.childAt(1).lexeme(), valueType, row,
                source.column(node.childAt(
                1)))
        return()
    }
    current.started = true
    if (kind.equals("label")) {
        declare(
                current.labels,
                node.childAt(0).lexeme(),
                current.length,
                row,
                col)
        return()
    }
    if (!kind.equals("instruction")) {
        fail("unexpected directive", row, col)
    }
    String mnemonic = node.childAt(0).lexeme()
    int64 opcode = CVM.Opcode.NOP
    while (opcode <= CVM.Opcode.RET_FILE
            && !schema.mnemonic(opcode).equals(
            mnemonic)) {
        opcode = opcode + 1
    }
    if (!schema.isValid(opcode)) {
        fail(format("unknown instruction '{}'", mnemonic), row, col)
    }
    bool hasOperand = schema.operandWidth(opcode) != 0
    if ((!hasOperand && node.childCount() != 1) || (hasOperand
            && node.childCount() != 2)) {
        fail("wrong operand count", row, col)
    }

    String operand = ""
    String operandKind = ""
    int64 literalValue = 0
    if (hasOperand) {
        AstNode value = node.childAt(1)
        AstNode token = value.childAt(0)
        operand = token.lexeme()
        operandKind = token.kind()
        int64 expected = schema.operandKind(opcode)
        if (expected == 1 || (expected == 2 && opcode != CVM.Opcode.SYS)) {
            literalValue = source.scalar(value, expected, literals)
        }
        else {
            if (!operandKind.equals("IDENT") || !literals.identifier(
                    operand)) {
                fail("expected named operand", row, source.column(value))
            }
        }
        col = source.column(value)
    }

    Instruction instruction = (
            Instruction(opcode, operand, row, col, current.length))
    instruction.value = literalValue
    current.instructions.append(instruction)
    current.length = current.length + 1 + schema.operandWidth(opcode)
    if (current.length > 4294967295) {
        fail("function code too large", row, col)
    }
}

/*
 * Compute resolve for this Assembler. Parameters: names is a list; name is a
 * String; instruction is an Instruction. It returns int64.
 */
int64 Assembler.resolve(list names, String name, Instruction instruction) {
    int64 index = find(names, name)
    if (index < 0) {
        fail(
                format("unresolved symbol '{}'", name),
                instruction.line,
                instruction.column)
    }
    return(index)
}
