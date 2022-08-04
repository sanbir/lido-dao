// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "@openzeppelin/contracts-v4.4/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-v4.4/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-v4.4/token/ERC20/utils/SafeERC20.sol";


/**
 * @title A vault for temporary storage of execution layer rewards (MEV and tx priority fee)
 */
abstract contract LidoExecutionLayerRewardsVaultBase {
    using SafeERC20 for IERC20;

    address public immutable LIDO;
    address public immutable TREASURY;

    /**
      * Emitted when the ERC20 `token` recovered (i.e. transferred)
      * to the Lido treasury address by `requestedBy` sender.
      */
    event ERC20Recovered(
        address indexed requestedBy,
        address indexed token,
        uint256 amount
    );

    /**
      * Emitted when the ERC721-compatible `token` (NFT) recovered (i.e. transferred)
      * to the Lido treasury address by `requestedBy` sender.
      */
    event ERC721Recovered(
        address indexed requestedBy,
        address indexed token,
        uint256 tokenId
    );

    /**
      * Emitted when the vault received ETH
      */
    event ETHReceived(
        uint256 amount
    );

    /**
      * Ctor
      *
      * @param _lido the Lido token (stETH) address
      * @param _treasury the Lido treasury address (see ERC20/ERC721-recovery interfaces)
      */
    constructor(address _lido, address _treasury) {
        require(_lido != address(0), "LIDO_ZERO_ADDRESS");
        require(_treasury != address(0), "TREASURY_ZERO_ADDRESS");

        LIDO = _lido;
        TREASURY = _treasury;
    }

    /**
      * @notice Allows the contract to receive ETH
      * @dev execution layer rewards may be sent as plain ETH transfers
      */
    receive() external payable {
        emit ETHReceived(msg.value);
    }

    /**
      * @notice Withdraw all accumulated rewards to Lido contract
      * @dev Can be called only by the Lido contract
      * @param _maxAmount Max amount of ETH or ERC-20 stake token to withdraw
      * @return amount of funds received as execution layer rewards (in wei)
      */
    function withdrawRewards(uint256 _maxAmount) virtual external returns (uint256 amount);

    /**
      * Transfers a given `_amount` of an ERC20-token (defined by the `_token` contract address)
      * currently belonging to the burner contract address to the Lido treasury address.
      *
      * @param _token an ERC20-compatible token
      * @param _amount token amount
      */
    function recoverERC20(address _token, uint256 _amount) external {
        require(_amount > 0, "ZERO_RECOVERY_AMOUNT");

        emit ERC20Recovered(msg.sender, _token, _amount);

        IERC20(_token).safeTransfer(TREASURY, _amount);
    }

    /**
      * Transfers a given token_id of an ERC721-compatible NFT (defined by the token contract address)
      * currently belonging to the burner contract address to the Lido treasury address.
      *
      * @param _token an ERC721-compatible token
      * @param _tokenId minted token id
      */
    function recoverERC721(address _token, uint256 _tokenId) external {
        emit ERC721Recovered(msg.sender, _token, _tokenId);

        IERC721(_token).transferFrom(address(this), TREASURY, _tokenId);
    }
}
