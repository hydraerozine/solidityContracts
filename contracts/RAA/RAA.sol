// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RAATEST is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct FreezeInfo {
        uint256 amount;
        uint256 unfreezeTime;
    }

    address private _feeRecipient;
    uint256 private _feePercent = 200; // Initial fee percent set to 2%
    uint256 private _minimumFee = 0; // Minimum fee 0%
    uint256 private _maximumFee = 700; // Maximum fee 7%
    address private _minter;
    address public merchantOffice;

    mapping(address => mapping(uint256 => FreezeInfo)) private _frozenBalances;
    mapping(address => uint256) private _frozenBalanceCount;

    // Event for fee payment
    event FeePaid(address indexed sender, address indexed recipient, uint256 amount);

    constructor(address feeRecipient_, address minter_)
        ERC20("Rare Astro Asset", "RAA") 
        Ownable(msg.sender)  // Pass the owner address to the Ownable constructor
    {
        _feeRecipient = feeRecipient_;
        _minter = minter_;
        _mint(_minter, 10000 * (10 ** uint256(decimals())));
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(sender != address(0), "RAA: Transfer from the zero address");
        require(recipient != address(0), "RAA: Transfer to the zero address");
        require(amount > 0, "RAA: Transfer amount must be greater than zero");

        uint256 totalFrozen = getFrozenBalance(sender);
        require(balanceOf(sender) >= amount + totalFrozen, "Insufficient balance");

        if (_feePercent > 0) {
            uint256 feeAmount = (amount * _feePercent) / 10000;
            uint256 transferAmount = amount - feeAmount;
            
            super._transfer(sender, _feeRecipient, feeAmount);
            super._transfer(sender, recipient, transferAmount);
            
            emit FeePaid(sender, _feeRecipient, feeAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }
    }

    function setMerchantOffice(address _merchantOffice) external onlyOwner {
        merchantOffice = _merchantOffice;
    }

    function freezeTokens(address owner, uint256 amount, uint256 duration) external nonReentrant {
        require(msg.sender == merchantOffice, "Only MerchantOffice can freeze tokens");
        require(balanceOf(owner) >= amount, "Insufficient balance");

        uint256 freezeId = _frozenBalanceCount[owner];
        _frozenBalances[owner][freezeId] = FreezeInfo({
            amount: amount,
            unfreezeTime: block.timestamp + duration // Use duration in seconds
        });
        _frozenBalanceCount[owner]++;

        emit TokensFrozen(owner, amount, duration);
    }

    function unfreezeTokens(address owner) external nonReentrant {
        require(msg.sender == merchantOffice, "Only MerchantOffice can unfreeze tokens");
        uint256 totalUnfrozen = 0;

        mapping(uint256 => FreezeInfo) storage frozenBalances = _frozenBalances[owner];
        uint256 frozenBalanceCount = _frozenBalanceCount[owner];

        for (uint256 i = 0; i < frozenBalanceCount; i++) {
            if (block.timestamp >= frozenBalances[i].unfreezeTime && frozenBalances[i].amount > 0) {
                totalUnfrozen += frozenBalances[i].amount;
                frozenBalances[i].amount = 0; // Mark as unfrozen
            }
        }

        // Remove frozen balance entries with zero amount
        for (uint256 i = frozenBalanceCount; i > 0; i--) {
            if (frozenBalances[i - 1].amount == 0) {
                delete frozenBalances[i - 1];
                frozenBalanceCount--;
            }
        }

        _frozenBalanceCount[owner] = frozenBalanceCount;

        require(totalUnfrozen > 0, "No tokens to unfreeze");
        emit TokensUnfrozen(owner, totalUnfrozen);
    }

    function getFrozenBalance(address owner) public view returns (uint256 totalFrozen) {
        mapping(uint256 => FreezeInfo) storage frozenBalances = _frozenBalances[owner];
        uint256 frozenBalanceCount = _frozenBalanceCount[owner];

        totalFrozen = 0;
        for (uint256 i = 0; i < frozenBalanceCount; i++) {
            if (block.timestamp < frozenBalances[i].unfreezeTime) {
                totalFrozen += frozenBalances[i].amount;
            }
        }
    }

    // Get the number of frozen balance entries for an owner
    function getNumberOfFrozenBalances(address owner) public view returns (uint256) {
        return _frozenBalanceCount[owner];
    }

    function getFrozenBalanceDetail(address owner, uint256 index) 
        public view returns (uint256 amount, uint256 unfreezeTime) 
    {
        require(index < _frozenBalanceCount[owner], "Index out of bounds");

        FreezeInfo storage freezeInfo = _frozenBalances[owner][index];
        amount = freezeInfo.amount;
        unfreezeTime = freezeInfo.unfreezeTime;
    }

    function setFeePercent(uint256 newFeePercent) public onlyOwner {
        require(newFeePercent >= _minimumFee && newFeePercent <= _maximumFee, 
                "RAA: Fee percent should be between 0% and 7%");
        _feePercent = newFeePercent;
    }

    function feeRecipient() public view returns (address) {
        return _feeRecipient;
    }

    function setFeeRecipient(address newFeeRecipient) public onlyOwner {
        _feeRecipient = newFeeRecipient;
    }

    function feePercent() public view returns (uint256) {
        return _feePercent;
    }

    // Events
    event TokensFrozen(address indexed owner, uint256 amount, uint256 duration);
    event TokensUnfrozen(address indexed owner, uint256 amount);
}