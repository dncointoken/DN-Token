pragma solidity ^0.4.21;

import "./LockTransfer.sol";

/**
 * @title TransferLimitedToken
 * @dev Token with ability to limit transfers within wallets included in limitedWallets list for certain period of time
 */
contract TransferLimitedToken is LockTransfer {
    uint256 public constant LIMIT_TRANSFERS_PERIOD = 365 days;

    mapping(address => bool) public limitedWallets;
    address public limitedWalletsManager;

    bool public isLimitEnabled = false;                             //Enable or Disable limit with limited Wallets
    bool public isLimitWithTime = false;                            //Enable or Disable limited wallets with time
    uint256 public limitEndDate;                                    //End of time for limited wallets

    event TransfersEnabled();

    /**
     * @dev TransferLimitedToken constructor
     * @param _listener Token listener(address can be 0x0)
     * @param _owner Owners list
     * @param _limitedWalletsManager Address used to add/del wallets from limitedWallets
     */
    constructor(
        address _listener,
        address _owner,
        address _limitedWalletsManager
    ) public LockTransfer(_listener, _owner)
    {
        limitedWalletsManager = _limitedWalletsManager;
    }   

    modifier onlyManager() {
        require(msg.sender == limitedWalletsManager || msg.sender == owner);
        _;
    }

    /** uint256 public constant LIMIT_TRANSFERS_PERIOD = 365 days;
     * @dev Check if transfer between addresses is available
     * @param _from From address
     * @param _to To address
     */
    modifier canTransfer(address _from, address _to)  {
        if(isLimitEnabled){
            if(limitedWallets[_from] || limitedWallets[_to]){
                if(isLimitWithTime){
                    if(now > limitEndDate){
                        isLimitEnabled = false;                        
                    }else{
                        require(false, "Wallet is limited in period time.");
                    }
                }else{
                    require(false, "Wallet is limited.");
                }
            }
        }
        _;
    }     

    /**
      Begin: Set params by manager
      _limitEndDateSecond is total of seconds for limit
    */
    function setLimitEndDate(uint256 _limitEndDateSecond) external onlyManager {
        isLimitEnabled = true;
        limitEndDate = now + _limitEndDateSecond;
    }

    /**
        Set list of limited wallets are existed in a year
     */
    function setLimitInAYear() external onlyManager {
        isLimitEnabled = true;
        limitEndDate = now + LIMIT_TRANSFERS_PERIOD;
    }

    /**
        Allow change account manage list of limited wallets
     */
    function changeLimitedWalletsManager(address _limitedWalletsManager) external onlyOwner{
        limitedWalletsManager = _limitedWalletsManager;
    }
     /**
      End: Set params by manager
    */

    /**
     * @dev Add address to limitedWallets
     * @dev Can be called only by manager
     */
    function addLimitedWalletAddress(address _wallet) public onlyManager {
        limitedWallets[_wallet] = true;
    }

    /**
     * @dev Del address from limitedWallets
     * @dev Can be called only by manager
     */
    function delLimitedWalletAddress(address _wallet) public onlyManager {
        limitedWallets[_wallet] = false;
    }

    /**
     * @dev Enable/Disable transfer limit manually. Can be called only by manager
     */
    function setAllowLimitedWallet(bool _isLimitEnabled) public onlyManager {
        isLimitEnabled = _isLimitEnabled;
    }

    /**
     * @dev Set time period for transfer limit manually. Can be called only by manager
     */
    function setAllowLimitedWalletWithTime(bool _isLimitWithTime) public onlyManager {
        isLimitWithTime = _isLimitWithTime;
    }

    /**
        Check condition when transfer token
     */
    function transfer(address _to, uint256 _value) public canTransfer(msg.sender, _to) checkLimitTimeTransfer  returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from, _to) checkLimitTimeTransfer returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public canTransfer(msg.sender, _spender) checkLimitTimeTransfer returns (bool) {
        return super.approve(_spender,_value);
    }    
}