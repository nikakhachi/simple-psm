// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockedReceiptToken is ERC20 {
  constructor() ERC20("ReceiptToken", "RT") {}

  function mint(address _to, uint256 _amount) external {
    _mint(_to, _amount);
  }

  function burnFrom(address _from, uint256 _amount) external {
    _burn(_from, _amount);
  }
}
