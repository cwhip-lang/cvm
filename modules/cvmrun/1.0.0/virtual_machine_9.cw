/*
 * modules/cvmrun/1.0.0/virtual_machine_9.cw — Out-of-line VirtualMachine
 * methods, part 9.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Report run for this VirtualMachine. The result is run(program,
     * Limits()). Parameters: program is a buffer. It returns ExecutionResult.
     */
    ExecutionResult VirtualMachine.run(buffer program) {
        return(run(program, Limits()))
    }

    /*
     * Report run for this VirtualMachine. The result is run(program, limits,
     * Capabilities()). Parameters: program is a buffer; limits is a Limits. It
     * returns ExecutionResult.
     */
    ExecutionResult VirtualMachine.run(buffer program, Limits limits) {
        return(run(program, limits, Capabilities()))
    }

    /*
     * Report run for this VirtualMachine. The result is run(program, Limits(),
     * capabilities). Parameters: program is a buffer; capabilities is a
     * Capabilities. It returns ExecutionResult.
     */
    ExecutionResult VirtualMachine.run(buffer program,
            Capabilities capabilities)
    {
        return(run(program, Limits(), capabilities))
    }

    /*
     * Compute run for this VirtualMachine. Parameters: program is a buffer;
     * limits is a Limits; capabilities is a Capabilities. It returns
     * ExecutionResult.
     */
    ExecutionResult VirtualMachine.run(
            buffer program,
            Limits limits,
            Capabilities capabilities) {
        reset(limits)
        if (limits == null || !limits.valid()) {
            _failure = ExecutionResult(ExecutionResult.CONFIGURATION_ERROR,
                    0,
                "invalid VM limits", 0, -1, -1, "", -1, _steps)
            return(_failure)
        }
        if (capabilities == null || !capabilities.valid()) {
            _failure = ExecutionResult(ExecutionResult.CONFIGURATION_ERROR,
                    0,
                "invalid host capabilities", 0, -1, -1, "", -1, _steps)
            return(_failure)
        }
        _capabilities = capabilities
        if (program == null) {
            loadFailure(0, 0, "program buffer is null")
            return(_failure)
        }
        if (program.length > limits.programBytes()) {
            failAt(
                    ExecutionResult.RESOURCE_LIMIT,
                    "program exceeds configured byte limit",
                    -1,
                    -1)
            return(_failure)
        }
        CVM.ContainerDecodeResult decoded = (
                CVM.ContainerDecoder().decode(program))
        if (!decoded.valid()) {
            validationFailure(decoded.validation())
            return(_failure)
        }
        if (!load(decoded)) {
            return(_failure)
        }
        if (!pushFrame(_entry, -1)) {
            return(_failure)
        }
        while (!_completed && _failure == null) {
            if (!executeOne() && _failure == null) {
                trap(
                        ExecutionResult.RUNTIME_TRAP,
                        "instruction did not complete")
            }
        }
        closeOwnedResources()
        if (_failure != null) {
            return(_failure)
        }
        return(ExecutionResult(
                ExecutionResult.SUCCESS,
                _guestResult,
                "",
            0,
                -1,
                -1,
                "",
                -1,
                _steps))
    }
}
