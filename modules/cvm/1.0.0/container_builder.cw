/*
 * modules/cvm/1.0.0/container_builder.cw — Assemble the seven required
 * sections, optional sections, and the v1 header and directory.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Assemble the seven required sections, optional sections, and the v1
     * header and directory.
     */
    class ContainerBuilder {
        private:
        list _sections
        buffer _code
        buffer _functions
        buffer _types
        buffer _globals
        buffer _arrays
        buffer _data
        buffer _strings
        buffer _debug
        int64 _debugCount
        bool _debugSet
        list _optionalSections
        list _functionNames
        list _globalNames
        list _arrayNames
        int64 _entry
        int64 _error
        String _message

        bool appendAll(buffer target, buffer source)

        int64 sectionCount(Section section)

        int64 appendString(String value)

        bool validIdentifier(String value)

        bool fail(int64 code, String message)

        bool nameExists(list names, String value)

        public:
        enum {
            OK = 0,
            INVALID_VALUE = 1,
            LIMIT_EXCEEDED = 2,
            INVALID_INSTRUCTION = 3
        }

        ContainerBuilder()

        bool setEntry(int64 functionIndex)

        bool addFunction(
                String name,
                buffer code,
                buffer localTypes,
                int64 parameterCount,
                int64 localCount,
                int64 maximumStack,
                int64 returnType)

        bool addGlobal(String name, int64 valueType, int64 initialValue)

        bool addArray(
                String name,
                int64 ownerFunction,
                int64 elementType,
                int64 length,
                buffer initialData)

        bool setDebug(buffer records, int64 count)

        bool addOptionalSection(int64 kind, buffer bytes, int64 count)

        int64 errorCode()

        String errorMessage()

        BuildResult encode()

    }
}
