pragma solidity ^0.4.21;

import "./ManagedToken.sol";

/**
 * @title LockTransfer
 * @dev Limit transfers for certain period of time
 */
contract LockTransfer is ManagedToken {
    bool public isLimitTimeTransfer = false;                        //Enable/Disable limit transfer for certain period of time
    uint256 public limitTimeTransferEndDate;                        //End of time for limit transfer

    event TransfersEnabled();

    /**
     * @dev LockTransfer constructor
     * @param _listener Token listener(address can be 0x0)
     * @param _owner Owner
     */
    constructor(
        address _listener,
        address _owner
    ) public ManagedToken(_listener, _owner)
    {
    }   

    /**
     * @dev Check if transfer is available at now
     */
    modifier checkLimitTimeTransfer()  {
        if(isLimitTimeTransfer){
            if(now > limitTimeTransferEndDate){
                isLimitTimeTransfer = false;
            }else{
                require(false, "Transfer is locking.");
            }
        }
        _;
    }     

    /**
     * @dev Enable/Disable transfer limit manually. Can be called only by owner
     */
    function setAllowLimitTimeTransfer(bool _isLimitTimeTransfer) public onlyOwner {
        isLimitTimeTransfer = _isLimitTimeTransfer;
    }

    /**
        Set time to end limit transfer
     */
    function setLimitTimeTransferEndDate(uint256 _limitTimeTransferEndDateSecond) public onlyOwner {
        isLimitTimeTransfer = true;
        limitTimeTransferEndDate = _limitTimeTransferEndDateSecond + now;
    }
}