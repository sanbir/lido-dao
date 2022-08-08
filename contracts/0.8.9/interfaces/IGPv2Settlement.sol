pragma solidity 0.8.9;

/**
  * @title CowSwap GPv2Settlement interface
  */
interface IGPv2Settlement {

    /// @dev Sets a presignature for the specified order UID.
    ///
    /// @param orderUid The unique identifier of the order to pre-sign.
    function setPreSignature(bytes calldata orderUid, bool signed) external;
}
