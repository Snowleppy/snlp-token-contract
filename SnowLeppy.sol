// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SnowLeppy
 * @dev Implementation of the SnowLeppy Token (SNLP) with a custom trading restriction phase.
 *
 * Disclaimer:
 * $SNLP is a meme coin with no intrinsic value or expectation of financial return.
 * There is no formal team or roadmap. The coin is completely useless and for entertainment purposes only.
 */
contract SnowLeppy is ERC20, Ownable {
    bool public tradingRestricted = true;
    address public liquidityPool;

    constructor() ERC20("SnowLeppy", "SNLP") Ownable(msg.sender) {
        uint256 initialSupply = 2e9 * (10 ** uint256(decimals()));
        _mint(msg.sender, initialSupply);
    }

    function setTradingRestricted(bool _state) external onlyOwner {
        tradingRestricted = _state;
    }

    function setLiquidityPool(address _liquidityPool) external onlyOwner {
        liquidityPool = _liquidityPool;
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._update(from, to, amount);

        if (liquidityPool == address(0)) {
            require(
                from == owner() || to == owner(),
                "Trading Has Not Started Yet"
            );
            return;
        }

        if (tradingRestricted && from != owner() && to != liquidityPool) {
            require(
                balanceOf(to) + amount <= totalSupply() / 100,
                "Transfer limit exceeded during trading restriction phase"
            );
        }
    }

    function renounceTokenOwnership() public onlyOwner {
        renounceOwnership();
    }
}
