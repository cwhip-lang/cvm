/*
 * modules/cvmrun/1.0.0/execution_result.cw — Own one finished or trapped
 * execution: category, guest result, location, and step count.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Own one finished or trapped execution: category, guest result, location,
     * and step count.
     */
    class ExecutionResult {
        private:
        int64 _category
        int64 _guestResult
        String _message
        int64 _section
        int64 _byteOffset
        int64 _functionIndex
        String _functionName
        int64 _instructionOffset
        int64 _instructionsExecuted

        public:
        enum {
            SUCCESS = 0,
            LOAD_ERROR = 1,
            VALIDATION_ERROR = 2,
            RUNTIME_TRAP = 3,
            UNSUPPORTED_SERVICE = 4,
            RESOURCE_LIMIT = 5,
            IO_ERROR = 6,
            CONFIGURATION_ERROR = 7
        }

        ExecutionResult(
                int64 category,
                int64 guestResult,
                String message,
                        int64 section,
                int64 byteOffset,
                int64 functionIndex,
                        String functionName,
                int64 instructionOffset,
                int64 steps)

        bool ok()

        int64 category()

        int64 guestResult()

        String message()

        int64 section()

        int64 byteOffset()

        int64 functionIndex()

        String functionName()

        int64 instructionOffset()

        int64 instructionsExecuted()

    }

    /*
     * Construct an ExecutionResult and store its initial fields (_category,
     * _guestResult, _message, _section, _byteOffset, _functionIndex,
     * _functionName, _instructionOffset, _instructionsExecuted). Parameters:
     * category is an int64; guestResult is an int64; message is a String;
     * section is an int64; byteOffset is an int64; functionIndex is an int64;
     * functionName is a String; instructionOffset is an int64; steps is an
     * int64. It constructs an ExecutionResult.
     */
    ExecutionResult ExecutionResult.ExecutionResult(
            int64 category,
            int64 guestResult,
            String message,
                    int64 section,
            int64 byteOffset,
            int64 functionIndex,
                    String functionName,
            int64 instructionOffset,
            int64 steps) {
        _category = category
        _guestResult = guestResult
        _message = message
        _section = section
        _byteOffset = byteOffset
        _functionIndex = functionIndex
        _functionName = functionName
        _instructionOffset = instructionOffset
        _instructionsExecuted = steps
    }

    /*
     * Report ok for this ExecutionResult. The result is _category == SUCCESS.
     * It takes no parameters. It returns bool.
     */
    bool ExecutionResult.ok() {
        return(_category == SUCCESS)
    }

    /*
     * Report category for this ExecutionResult. The result is _category. It
     * takes no parameters. It returns int64.
     */
    int64 ExecutionResult.category() {
        return(_category)
    }

    /*
     * Report guest result for this ExecutionResult. The result is
     * _guestResult. It takes no parameters. It returns int64.
     */
    int64 ExecutionResult.guestResult() {
        return(_guestResult)
    }

    /*
     * Report message for this ExecutionResult. The result is _message. It
     * takes no parameters. It returns String.
     */
    String ExecutionResult.message() {
        return(_message)
    }

    /*
     * Report section for this ExecutionResult. The result is _section. It
     * takes no parameters. It returns int64.
     */
    int64 ExecutionResult.section() {
        return(_section)
    }

    /*
     * Report byte offset for this ExecutionResult. The result is _byteOffset.
     * It takes no parameters. It returns int64.
     */
    int64 ExecutionResult.byteOffset() {
        return(_byteOffset)
    }

    /*
     * Report function index for this ExecutionResult. The result is
     * _functionIndex. It takes no parameters. It returns int64.
     */
    int64 ExecutionResult.functionIndex() {
        return(_functionIndex)
    }

    /*
     * Report function name for this ExecutionResult. The result is
     * _functionName. It takes no parameters. It returns String.
     */
    String ExecutionResult.functionName() {
        return(_functionName)
    }

    /*
     * Report instruction offset for this ExecutionResult. The result is
     * _instructionOffset. It takes no parameters. It returns int64.
     */
    int64 ExecutionResult.instructionOffset() {
        return(_instructionOffset)
    }

    /*
     * Report instructions executed for this ExecutionResult. The result is
     * _instructionsExecuted. It takes no parameters. It returns int64.
     */
    int64 ExecutionResult.instructionsExecuted() {
        return(_instructionsExecuted)
    }
}
