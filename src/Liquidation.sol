// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/utils/math/SafeMath.sol";

import "./uniswap/IUniswapV2Router.sol";
import "./uniswap/v3/ISwapRouter.sol";

import "./balancer/IBalancerVault.sol";
import "./balancer/IFlashLoanRecipient.sol";

import "./aave/ILendingPool.sol";

contract Liquidation is IFlashLoanRecipientBalancer {
    using SafeMath for uint256;

    IBalancerVault private immutable vault;
    ILendingPool private immutable lendingPool;

	struct FlashLoanData {
		address user;
		address collateralAsset;
	}

	constructor(address _vault, address _lendingPool) {
        vault = IBalancerVault(_vault);
        lendingPool = ILendingPool(_lendingPool);
	}


    function flashloan(address token, uint256 amount, address user, address collateralAsset) external {
        bytes memory data = abi.encode(
            FlashLoanData({
                user: user,
				collateralAsset: collateralAsset
            })
        );
        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = IERC20(token);
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        vault.flashLoan(
            IFlashLoanRecipientBalancer(address(this)),
            tokens,
            amounts,
            data
        );
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory,
        bytes memory userData
    ) external override {
        FlashLoanData memory decoded = abi.decode(userData, (FlashLoanData));
        IERC20 loanToken = tokens[0];
        uint256 loanAmount = amounts[0];
        address user = decoded.user;
        address collateralAsset = decoded.collateralAsset;
        uint256 amountOut = liquidation(collateralAsset, address(loanToken), user, loanAmount);
		uniswapV3(amountOut, collateralAsset, address(loanToken));

        //Return funds
        loanToken.transfer(address(vault), loanAmount);
    }

    function liquidation(
        address collateralAsset,
        address debtAsset,
        address user,
		uint256 debtToCover
    ) internal returns (uint256) {
        (, , , , , uint256 healthFactor) = lendingPool.getUserAccountData(user);

		// check health factor
        require(healthFactor < 1 ether, "health factor too high");

        approveToken(debtAsset, address(lendingPool), debtToCover);
        lendingPool.liquidationCall(
            collateralAsset,
            debtAsset,
            user,
            debtToCover,
            false
        );
        uint256 amountOut = IERC20(collateralAsset).balanceOf(address(this));
        return amountOut;
    }

    function uniswapV3(
        uint256 amountIn,
		address tokenIn,
		address tokenOut
    ) internal returns (uint256 amountOut) {
		address router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
		uint24 fee = 3000;
		address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        ISwapRouter swapRouter = ISwapRouter(router);
        approveToken(tokenIn, address(swapRouter), amountIn);
        // multi hop swaps
        amountOut = swapRouter.exactInput(
            ISwapRouter.ExactInputParams({
				path: abi.encodePacked(tokenIn, fee, WETH, fee, tokenOut),
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0
            })
        );
    }

    function approveToken(
        address token,
        address to,
        uint256 amountIn
    ) internal {
        require(IERC20(token).approve(to, amountIn), "approve failed");
    }
}
