/*
 * modules/cvm/1.0.0/container_decoder.cw — Validate a container and wrap the
 * accepted bytes for callers that want section access.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace CVM {
    /*
     * Validate a container and wrap the accepted bytes for callers that want
     * section access.
     */
    class ContainerDecoder {
        public:
        ContainerDecodeResult decode(buffer bytes)

    }

    /*
     * Compute decode for this ContainerDecoder. Parameters: bytes is a buffer.
     * It returns ContainerDecodeResult.
     */
    ContainerDecodeResult ContainerDecoder.decode(buffer bytes) {
        ValidationResult validation = ContainerValidator().validate(bytes)
        return(ContainerDecodeResult(bytes, validation))
    }
}
