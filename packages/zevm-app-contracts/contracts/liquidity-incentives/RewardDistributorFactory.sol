// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@zetachain/zevm-protocol-contracts/contracts/system/SystemContract.sol";

import "./RewardDistributor.sol";

contract RewardDistributorFactory {
    address public immutable zetaTokenAddress;
    SystemContract private immutable systemContract;

    mapping(uint256 => address) public incentivesContracts;
    uint256 public incentivesContractsLen;

    event RewardDistributorCreated(
        address rewardDistributorContract,
        address stakingTokenA,
        address stakingTokenB,
        address LPStakingToken,
        address rewardToken,
        address owner
    );

    constructor(address _zetaTokenAddress, address _systemContract) {
        zetaTokenAddress = _zetaTokenAddress;
        systemContract = SystemContract(_systemContract);
    }

    function createTokenIncentive(
        address owner,
        ///@dev _rewardsDistribution is one who can set the amount of token to reward
        address rewardsDistribution,
        address stakingTokenA,
        address stakingTokenB
    ) public {
        if (stakingTokenB == address(0)) {
            stakingTokenB = zetaTokenAddress;
        }
        address LPTokenAddress = systemContract.uniswapv2PairFor(
            systemContract.uniswapv2FactoryAddress(),
            stakingTokenA,
            stakingTokenB
        );
        RewardDistributor incentiveContract = new RewardDistributor(
            owner,
            rewardsDistribution,
            zetaTokenAddress,
            LPTokenAddress,
            stakingTokenA,
            stakingTokenB,
            address(systemContract)
        );
        incentivesContracts[incentivesContractsLen++] = address(incentiveContract);

        emit RewardDistributorCreated(
            address(incentiveContract),
            stakingTokenA,
            stakingTokenB,
            LPTokenAddress,
            zetaTokenAddress,
            owner
        );
    }

    function getIncentiveContracts() public view returns (address[] memory) {
        address[] memory result = new address[](incentivesContractsLen);
        for (uint256 i = 0; i < incentivesContractsLen; i++) {
            result[i] = incentivesContracts[i];
        }
        return result;
    }
}
