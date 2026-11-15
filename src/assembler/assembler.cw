/*
 * src/assembler/assembler.cw — Translation unit for cvm-as. It assembles one
 * source file into a container.
 *
 * Created: 2026-10-22
 * Author: Charles Tilbury
 *
 * Changelog:
 *   2026-10-22  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "parser.cw"
include "model.cw"
include "literals.cw"
include "source.cw"
include "stack.cw"
import cvmfile as IO
import cli as Cli

include "assemble.cw"
include "assemble_1.cw"
include "assemble_2.cw"
include "assemble_3.cw"
include "assembler_cli.cw"

start {
    Sys.Process().exit(AssemblerCLI().run())
}
