/*
 * modules/cvm/1.0.0/container_validator.cw — Check the structural rules of a
 * v1 container. It does not check stack types or reachable execution.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Check the structural rules of a v1 container. It does not check stack
     * types or reachable execution.
     */
    class ContainerValidator {
        private:
        Section findSection(list sections, int64 kind)

        ValidationResult reject(
                int64 code,
                int64 section,
                int64 offset,
                String message)

        bool validName(
                buffer bytes,
                int64 stringsStart,
                int64 stringsLength,
                int64 offset)

        bool sameName(
                buffer bytes,
                int64 stringsStart,
                int64 first,
                int64 second)

        public:
        ValidationResult validate(buffer bytes)

    }
}
