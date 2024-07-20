// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BLITZB is Ownable, ReentrancyGuard {
    uint256 public feeCit = 1e20; // 100 CIT
    uint256 public feeBnbUsd = 9e18; // 9 USD in BNB (will be dynamically calculated)

    address public nina;
    address public gnome;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public depositsBnb;
    mapping(address => uint256) public depositsRaa;
    mapping(string => uint256) public depositsGlobal;
    mapping(string => uint256) public depositsBnbGlobal;
    mapping(string => uint256) public totalBnbFee;

    IERC20 public citToken;
    IERC20 public raaToken;
    IERC20 public usdToken; // BUSD or another stable USD token on BSC

    event Deposit(address indexed user, uint256 amount, string tokenSymbol);
    event Withdraw(address indexed user, uint256 amount, string tokenSymbol);
    event Blitz(address indexed user, uint256 amount, string chainID, address destinationAddress);

    constructor(
        address _citToken,
        address _raaToken,
        address _usdToken,
        address _nina,
        address _gnome,
        address initialOwner
    ) Ownable(initialOwner) ReentrancyGuard() {
        citToken = IERC20(_citToken);
        raaToken = IERC20(_raaToken);
        usdToken = IERC20(_usdToken);
        nina = _nina;
        gnome = _gnome;
    }

    function setNina(address newNina) external onlyOwner {
        nina = newNina;
    }

    function setGnome(address newGnome) external onlyOwner {
        gnome = newGnome;
    }

    function updateBnbFee(uint256 amountUsd) external onlyOwner {
        feeBnbUsd = amountUsd;
    }

    function updateCitFee(uint256 amount) external onlyOwner {
        feeCit = amount;
    }

    function getDeposit(address from, string memory symbol) external view returns (uint256) {
        if (keccak256(abi.encodePacked(symbol)) == keccak256(abi.encodePacked("CIT"))) {
            return deposits[from];
        } else if (keccak256(abi.encodePacked(symbol)) == keccak256(abi.encodePacked("BNB"))) {
            return depositsBnb[from];
        } else if (keccak256(abi.encodePacked(symbol)) == keccak256(abi.encodePacked("RAA"))) {
            return depositsRaa[from];
        }
        return 0;
    }

    function getGlobalDeposits(string memory symbol) external view returns (uint256) {
        return depositsGlobal[symbol];
    }

    function getGlobalBnbDeposits(string memory symbol) external view returns (uint256) {
        return depositsBnbGlobal[symbol];
    }

    function getGlobalBnbFee(string memory symbol) external view returns (uint256) {
        return totalBnbFee[symbol];
    }

    function calculateBnbFee() public view returns (uint256) {
        // This function needs to be implemented to calculate the BNB fee
        // without relying on PancakeRouter
        return feeBnbUsd; // Placeholder implementation
    }

    function depositBnb() external payable nonReentrant {
        uint256 feeBnb = calculateBnbFee();
        require(msg.value > feeBnb, "Amount must be greater than fee");

        uint256 amountMinusFee = msg.value - feeBnb;
        payable(nina).transfer(feeBnb);

        depositsBnb[msg.sender] += amountMinusFee;
        depositsBnbGlobal["BNB"] += amountMinusFee;
        totalBnbFee["BNB"] += feeBnb;

        emit Deposit(msg.sender, amountMinusFee, "BNB");
    }

    function deposit(uint256 amount) external nonReentrant {
        require(citToken.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(amount > feeCit, "Amount must be greater than fee");

        uint256 amountMinusFee = amount - feeCit;
        require(citToken.transferFrom(msg.sender, gnome, feeCit), "Fee transfer failed");
        require(citToken.transferFrom(msg.sender, address(this), amountMinusFee), "Deposit transfer failed");

        deposits[msg.sender] += amountMinusFee;
        depositsGlobal["CIT"] += amountMinusFee;

        emit Deposit(msg.sender, amountMinusFee, "CIT");
    }

    function withdraw(uint256 amount, string memory symbol) external nonReentrant {
        if (keccak256(abi.encodePacked(symbol)) == keccak256(abi.encodePacked("CIT"))) {
            require(deposits[msg.sender] >= amount, "Insufficient CIT balance");
            require(citToken.balanceOf(address(this)) >= amount, "Contract has insufficient CIT balance");

            uint256 feeBnb = calculateBnbFee();
            require(depositsBnb[msg.sender] >= feeBnb, "Insufficient BNB balance for fee");

            deposits[msg.sender] -= amount;
            depositsBnb[msg.sender] -= feeBnb;
            require(citToken.transfer(msg.sender, amount), "CIT transfer failed");
            payable(nina).transfer(feeBnb);

            depositsGlobal["CIT"] -= amount;
            depositsBnbGlobal["BNB"] -= feeBnb;
            totalBnbFee["BNB"] += feeBnb;

        } else if (keccak256(abi.encodePacked(symbol)) == keccak256(abi.encodePacked("RAA"))) {
            require(depositsRaa[msg.sender] >= amount, "Insufficient RAA balance");
            require(raaToken.balanceOf(address(this)) >= amount, "Contract has insufficient RAA balance");

            uint256 feeBnb = calculateBnbFee();
            require(depositsBnb[msg.sender] >= feeBnb, "Insufficient BNB balance for fee");

            depositsRaa[msg.sender] -= amount;
            depositsBnb[msg.sender] -= feeBnb;
            require(raaToken.transfer(msg.sender, amount), "RAA transfer failed");
            payable(nina).transfer(feeBnb);

            depositsGlobal["RAA"] -= amount;
            depositsBnbGlobal["BNB"] -= feeBnb;
            totalBnbFee["BNB"] += feeBnb;

        } else {
            revert("Invalid token symbol");
        }

        emit Withdraw(msg.sender, amount, symbol);
    }

    function blitz(uint256 amount, string memory chainID, address destinationAddress) external nonReentrant {
        require(msg.sender == nina, "Only Nina can call this function");
        require(deposits[destinationAddress] >= amount, "Insufficient CIT balance");

        uint256 feeBnb = calculateBnbFee();
        require(depositsBnb[destinationAddress] >= feeBnb, "Insufficient BNB balance for fee");

        uint256 amountMinusFee = amount - feeCit;
        deposits[destinationAddress] -= amount;
        depositsBnb[destinationAddress] -= feeBnb;
        depositsGlobal["CIT"] -= amount;
        depositsBnbGlobal["BNB"] -= feeBnb;
        totalBnbFee["BNB"] += feeBnb;

        require(citToken.transfer(gnome, feeCit), "Fee transfer failed");
        payable(nina).transfer(feeBnb);

        emit Blitz(destinationAddress, amountMinusFee, chainID, destinationAddress);
    }

    receive() external payable {}
}