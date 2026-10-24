// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title NewmanAIToken
 * @notice Global Holistic Liberal Education, Conscience & University Launchpad ($NEWMAN)
 * @dev Direct micro-escrows for liberal arts scholarships, philosophical research, and intellectual formation
 */
contract NewmanAIToken {
    string public name = "Newman AI";
    string public symbol = "NEWMAN";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public constant INITIAL_PRICE = 0.0001 ether;
    uint256 public constant CURVE_SLOPE = 1e10;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event CurveMint(address indexed scholar, uint256 tokenAmount, uint256 ethDonation);
    event AcademyDisbursement(string indexed discipline, address indexed scholar, uint256 amountWei, bytes32 indexed researchHash);

    function calculateCost(uint256 amount) public view returns (uint256) {
        uint256 currentSupply = totalSupply;
        uint256 baseCost = amount * INITIAL_PRICE;
        uint256 curveFactor = (CURVE_SLOPE * ((currentSupply + amount)**2 - currentSupply**2)) / 2e18;
        return baseCost + curveFactor;
    }

    function mint(uint256 amount) external payable returns (bool) {
        require(amount > 0, "Zero donation amount");
        uint256 cost = calculateCost(amount);
        require(msg.value >= cost, "Insufficient donation for bonding curve");

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
        emit CurveMint(msg.sender, amount, cost);

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        return true;
    }

    function disburseAcademyGrant(
        string memory discipline,
        address scholar,
        uint256 amount,
        bytes32 researchHash
    ) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient academy treasury reserve");
        balanceOf[msg.sender] -= amount;
        balanceOf[scholar] += amount;
        emit Transfer(msg.sender, scholar, amount);
        emit AcademyDisbursement(discipline, scholar, amount, researchHash);
        return true;
    }
}
