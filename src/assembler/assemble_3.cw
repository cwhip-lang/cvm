/*
 * src/assembler/assemble_3.cw — Out-of-line Assembler methods, part 3.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Compute encode for this Assembler. Parameters: text is a buffer. It returns
 * buffer.
 */
buffer Assembler.encode(buffer text) {
    SourceText().validate(text)

    int64 index = 0
    int64 lineStart = 0
    int64 row = 1
    while (index <= text.length) {
        if (index == text.length || int64(text[index]) == 10) {
            SourceLine line = SourceLine(text[lineStart:index], row)
            AstNode node = line.parse()
            if (node != null) {
                consume(node, line)
            }
            row = row + 1
            lineStart = index + 1
        }
        index = index + 1
    }

    if (!version || entry.equals("")) {
        fail("missing .version or .entry", 1, 1)
    }
    if (current != null) {
        fail("missing .end", current.line, 1)
    }
    int64 entryIndex = find(functionNames, entry)
    if (entryIndex < 0) {
        fail("unresolved entry function", entryLine, 1)
    }
    Function main = functions[entryIndex] as Function
    if (main.parameters != 0 || main.result != 1) {
        fail("entry must be main() -> i32", main.line, 1)
    }
    CVM.ContainerBuilder builder = CVM.ContainerBuilder()
    builder.setEntry(entryIndex)
    index = 0

    while (index < functions.length) {

        Function function = functions[index] as Function
        CVM.InstructionBuilder code = CVM.InstructionBuilder()
        int64 at = 0
        while (at < function.instructions.length) {

            Instruction instruction = (
                    function.instructions[at] as Instruction)
            int64 kind = schema.operandKind(instruction.opcode)
            int64 value = instruction.value
            if (instruction.opcode == CVM.Opcode.SYS) {
                CVM.Service services = CVM.Service()
                while (value <= CVM.Service.FILE_CLOSE_HANDLE
                        && !services.name(
                        value).equals(
                        instruction.operand)) {
                    value = value + 1
                }
                if (value > CVM.Service.FILE_CLOSE_HANDLE) {
                    fail(
                            "unknown service",
                            instruction.line,
                            instruction.column)
                }
            }

            if (kind == 3) {
                value = (
                        resolve(function.locals, instruction.operand,
                        instruction))
            }
            if (kind == 4) {
                value = (
                        resolve(globalNames, instruction.operand,
                        instruction))
            }
            if (kind == 5) {
                value = (
                        resolve(arrayNames, instruction.operand,
                        instruction))
                ArrayDeclaration array = arrays[value] as ArrayDeclaration
                if (array.owner != 65535 && array.owner != index) {
                    fail(
                            "array belongs to another function",
                            instruction.line,
                            instruction.column)
                }
            }
            if (kind == 6) {
                value = (
                        resolve(function.labels, instruction.operand,
                        instruction))
                if (value >= function.length) {
                    fail(
                            "label target is past function end",
                            instruction.line,
                            instruction.column)
                }
            }
            if (kind == 7) {
                value = (
                        resolve(functionNames, instruction.operand,
                        instruction))
            }
            instruction.value = value
            bool ok = true
            if (kind == 0) {
                ok = code.emitNoOperand(instruction.opcode)
            }
            else {
                ok = code.emit(instruction.opcode, value)
            }
            if (!ok) {
                fail(
                        code.errorMessage(),
                        instruction.line,
                        instruction.column)
            }
            at = at + 1
        }

        int64 maximum = StackDepth().maximum(function, functions)
        if (!builder.addFunction(
                function.name,
                code.bytes(),
                function.types,
                function.parameters,
                function.types.length - function.parameters,
                maximum,
                function.result)) {
            fail(builder.errorMessage(), function.line, 1)
        }
        index = index + 1
    }

    index = 0
    while (index < globals.length) {
        GlobalDeclaration global = globals[index] as GlobalDeclaration
        if (!builder.addGlobal(global.name, global.valueType,
                global.value)) {
            fail(builder.errorMessage(), 1, 1)
        }
        index = index + 1
    }
    index = 0

    while (index < arrays.length) {
        ArrayDeclaration array = arrays[index] as ArrayDeclaration
        if (!builder.addArray(
                array.name,
                array.owner,
                array.element,
                array.count,
                array.data)) {
            fail(builder.errorMessage(), 1, 1)
        }
        index = index + 1
    }

    CVM.BuildResult result = builder.encode()
    if (!result.ok()) {
        fail(result.message(), 1, 1)
    }
    CVM.ValidationResult validation = (
            CVM.ContainerValidator().validate(result.bytes()))
    if (!validation.valid()) {
        fail(
                format("structural validation: {}", validation.message()),
                1,
                1)
    }
    return(result.bytes())
}
