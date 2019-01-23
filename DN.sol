pragma solidity ^0.4.21;

import "./token/TransferLimitedToken.sol";

/**
 * DN Token Contract
 * @title DN
 */
contract DN is TransferLimitedToken {
    bool public isLock = false;                                                 //Lock system
    uint256 public lockTotal;                                                   //Total token is lock
    uint256 public unlockTotal;                                                 //Total token is unlock
    uint256 public lockEndTime;                                                 //Time end of lock

    uint256 public LOCK_WITH_FOUR_WEEKS = 28 days;
    uint256 public LOCK_WITH_EIGHT_WEEKS = 56 days;
    uint256 public LOCK_WITH_TWELVE_WEEKS = 84 days;
    uint256 public LOCK_WITH_ONE_YEAR = 365 days;

    /**
     * @dev DN constructor
     */
    constructor() public TransferLimitedToken(msg.sender, msg.sender, msg.sender) {
        name = "DN";
        symbol = "DN";
        decimals = 18;
        totalIssue = 0;
        totalSupply = 200000000 ether;                                          //The maximum number of tokens is unchanged and totals will decrease after issue
        lockTotal = 80000000 ether;                                             //Total tokens to lock
        unlockTotal = 120000000 ether;                                          //Total tokens to lock
    }

    function issue(address _to, uint256 _value) external onlyOwner canIssue {
        totalIssue = safeAdd(totalIssue, _value);
        require(totalSupply >= totalIssue, "Total issue is not greater total of supply");

        if(isLock){
            if(now > lockEndTime){
                isLock = false;
            }else{
                require(totalIssue <= unlockTotal, "totalIssue is required less than value of unlockTotal.");            
            }
        }
        
        balances[_to] = safeAdd(balances[_to], _value);
        //Call event
        emit Issue(_to, _value);
        emit Transfer(address(0), _to, _value);
    }

    function setLock(bool _isLock) external onlyOwner {
        isLock = _isLock;
    }

    /**
        Set total of token to lock for certain period of tim
     */
    function setLockTotal(uint256 _lockTotal) external onlyOwner {
        lockTotal = _lockTotal;
        unlockTotal = safeSub(totalSupply, lockTotal);
    }

    /**
        Set time to end lock token
     */
    function setLockEndTime(uint256 _lockEndTimeSecond) external onlyOwner {
        isLock = true;
        lockEndTime = _lockEndTimeSecond + now;
    }

    /**
        Set lock a part of token in four weeks 
    */
    function setLockFourWeeks() external onlyOwner {
        isLock = true;
        lockEndTime = LOCK_WITH_FOUR_WEEKS + now;
    }

    /**
        Set lock a part of token in eight weeks
     */
    function setLockEightWeeks() external onlyOwner {
        isLock = true;
        lockEndTime = LOCK_WITH_EIGHT_WEEKS + now;
    }

    /**
        Set lock a part of token in twelve weeks
     */
    function setLockTwelveWeeks() external onlyOwner {
        isLock = true;
        lockEndTime = LOCK_WITH_TWELVE_WEEKS + now;
    }

    /**
        Set lock a part of token in a year
     */
    function setLockAYear() external onlyOwner {
        isLock = true;
        lockEndTime = LOCK_WITH_ONE_YEAR + now;
    }
}