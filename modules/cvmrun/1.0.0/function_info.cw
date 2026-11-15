/*
 * modules/cvmrun/1.0.0/function_info.cw — Own the loaded metadata for one
 * function, including its code extent and local types.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVMRun {
    /*
     * Own the loaded metadata for one function, including its code extent and
     * local types.
     */
    class FunctionInfo {
        private:
        String _name
        int64 _codeOffset
        int64 _codeLength
        int64 _typeOffset
        int64 _parameters
        int64 _locals
        int64 _maximumStack
        int64 _returnType
        list _localArrayIndexes

        public:
        FunctionInfo(
                String name,
                int64 codeOffset,
                int64 codeLength,
                int64 typeOffset,
                     int64 parameters,
                int64 locals,
                int64 maximumStack,
                int64 returnType)

        String name()

        int64 codeOffset()

        int64 codeLength()

        int64 typeOffset()

        int64 parameters()

        int64 locals()

        int64 maximumStack()

        int64 returnType()

        list localArrayIndexes()

        void addLocalArray(int64 index)

    }

    /*
     * Construct a FunctionInfo and store its initial fields (_name,
     * _codeOffset, _codeLength, _typeOffset, _parameters, _locals,
     * _maximumStack, _returnType, _localArrayIndexes). Parameters: name is a
     * String; codeOffset is an int64; codeLength is an int64; typeOffset is an
     * int64; parameters is an int64; locals is an int64; maximumStack is an
     * int64; returnType is an int64. It constructs a FunctionInfo.
     */
    FunctionInfo FunctionInfo.FunctionInfo(
            String name,
            int64 codeOffset,
            int64 codeLength,
            int64 typeOffset,
                 int64 parameters,
            int64 locals,
            int64 maximumStack,
            int64 returnType) {
        _name = name
        _codeOffset = codeOffset
        _codeLength = codeLength
        _typeOffset = typeOffset
        _parameters = parameters
        _locals = locals
        _maximumStack = maximumStack
        _returnType = returnType
        _localArrayIndexes = []
    }

    /*
     * Report name for this FunctionInfo. The result is _name. It takes no
     * parameters. It returns String.
     */
    String FunctionInfo.name() {
        return(_name)
    }

    /*
     * Report code offset for this FunctionInfo. The result is _codeOffset. It
     * takes no parameters. It returns int64.
     */
    int64 FunctionInfo.codeOffset() {
        return(_codeOffset)
    }

    /*
     * Report code length for this FunctionInfo. The result is _codeLength. It
     * takes no parameters. It returns int64.
     */
    int64 FunctionInfo.codeLength() {
        return(_codeLength)
    }

    /*
     * Report type offset for this FunctionInfo. The result is _typeOffset. It
     * takes no parameters. It returns int64.
     */
    int64 FunctionInfo.typeOffset() {
        return(_typeOffset)
    }

    /*
     * Report parameters for this FunctionInfo. The result is _parameters. It
     * takes no parameters. It returns int64.
     */
    int64 FunctionInfo.parameters() {
        return(_parameters)
    }

    /*
     * Report locals for this FunctionInfo. The result is _locals. It takes no
     * parameters. It returns int64.
     */
    int64 FunctionInfo.locals() {
        return(_locals)
    }

    /*
     * Report maximum stack for this FunctionInfo. The result is _maximumStack.
     * It takes no parameters. It returns int64.
     */
    int64 FunctionInfo.maximumStack() {
        return(_maximumStack)
    }

    /*
     * Report return type for this FunctionInfo. The result is _returnType. It
     * takes no parameters. It returns int64.
     */
    int64 FunctionInfo.returnType() {
        return(_returnType)
    }

    /*
     * Report local array indexes for this FunctionInfo. The result is
     * _localArrayIndexes. It takes no parameters. It returns list.
     */
    list FunctionInfo.localArrayIndexes() {
        return(_localArrayIndexes)
    }

    /*
     * Perform add local array on this FunctionInfo. Parameters: index is an
     * int64. It does not return a value.
     */
    void FunctionInfo.addLocalArray(int64 index) {
        _localArrayIndexes.append(index)
    }
}
