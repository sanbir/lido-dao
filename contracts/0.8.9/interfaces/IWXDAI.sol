pragma solidity 0.8.9;

import "@openzeppelin/contracts-v4.4/token/ERC20/IERC20.sol";

/**
  * @title Wrapped XDAI interface
  */
interface IWXDAI is IERC20 {
    function deposit() external payable;
}
