/*
 * src/assembler/assembler_cli.cw — Parse cvm-as argv and write the assembled
 * container. Usage failures exit 2 and assembly failures exit 1.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Parse cvm-as argv and write the assembled container. Usage failures exit 2
 * and assembly failures exit 1.
 */
class AssemblerCLI {
    public:
    String usage()

    Cli.CommandLine parser()

    int64 run()

}

/*
 * Report usage for this AssemblerCLI. The result is "usage: cvm-as INPUT.asm
 * -o OUTPUT.cvm". It takes no parameters. It returns String.
 */
String AssemblerCLI.usage() {
    return("usage: cvm-as INPUT.asm -o OUTPUT.cvm")
}

/*
 * Compute parser for this AssemblerCLI. It takes no parameters. It returns
 * Cli.CommandLine.
 */
Cli.CommandLine AssemblerCLI.parser() {
    Cli.CommandLine commandLine = (
            Cli.CommandLine("cvm-as", "assemble CVM bytecode", "1.0.0"))
    Cli.Option help = Cli.Option()
    help.longName = "help"
    help.name = "help"
    help.action = Cli.Action().HELP
    commandLine.addOption(help)
    Cli.Option output = Cli.Option()
    output.shortName = "o"
    output.name = "output"
    output.description = "output container path"
    output.valueType = Cli.ValueType().STRING
    output.required = true
    commandLine.addOption(output)
    Cli.Positional input = Cli.Positional()
    input.name = "input"
    input.description = "assembly source"
    input.required = true
    commandLine.addPositional(input)
    return(commandLine)
}

/*
 * Compute run for this AssemblerCLI. It raises on failure. It takes no
 * parameters. It returns int64.
 */
int64 AssemblerCLI.run() {
    Cli.CommandLine commandLine = parser()
    try {
        commandLine.parseArgv()
    }
    except() as error {
        Sys.StandardIO().writeErrorLine(usage())
        return(2)
    }
    if (commandLine.currentAction() == Cli.Action().HELP) {
        Sys.StandardIO().writeLine(usage())
        return(0)
    }
    if (commandLine.wasProvided("output") == false
            or commandLine.allPositionalValues().length != 1) {
        Sys.StandardIO().writeErrorLine(usage())
        return(2)
    }
    String input = commandLine.allPositionalValues()[0] as String
    String output = commandLine.value("output")
    try {
        IO.Result source = IO.Files().read(input)
        if (!source.ok()) {
            raise(Exception(source.error()))
        }
        buffer bytes = Assembler().encode(source.bytes())
        IO.Result saved = IO.Files().write(output, bytes)
        if (!saved.ok()) {
            raise(Exception(saved.error()))
        }
    }
    except(AssemblyError) as diagnostic {
        AssemblyError located = diagnostic as AssemblyError
        Sys.StandardIO().writeErrorLine(format(
                "{}:{}:{}: {}",
                input,
                located.line,
                located.column,
                located.message))
        return(1)
    }
    except(Exception) as error {
        Sys.StandardIO().writeErrorLine(format(
                "{}: I/O: {}",
                input,
                error.message))
        return(1)
    }
    return(0)
}
