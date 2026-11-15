/*
 * modules/cvm/1.0.0/branch_target.cw — Remember a function-relative branch
 * target so the validator can check it after the code extent is known.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Remember a function-relative branch target so the validator can check it
     * after the code extent is known.
     */
    class BranchTarget {
        private:
        int64 _functionOffset
        int64 _target

        public:
        BranchTarget(int64 functionOffset, int64 target)

        int64 functionOffset()

        int64 target()

    }

    /*
     * Construct a BranchTarget and store its initial fields (_functionOffset,
     * _target). Parameters: functionOffset is an int64; target is an int64. It
     * constructs a BranchTarget.
     */
    BranchTarget BranchTarget.BranchTarget(int64 functionOffset, int64 target)
    {
        _functionOffset = functionOffset
        _target = target
    }

    /*
     * Report function offset for this BranchTarget. The result is
     * _functionOffset. It takes no parameters. It returns int64.
     */
    int64 BranchTarget.functionOffset() {
        return(_functionOffset)
    }

    /*
     * Report target for this BranchTarget. The result is _target. It takes no
     * parameters. It returns int64.
     */
    int64 BranchTarget.target() {
        return(_target)
    }
}
