// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IReceiptToken} from "./interfaces/IReceiptToken.sol";

contract PSM is AccessControl {
  bytes32 public constant MANAGER = keccak256(abi.encode("manager"));

  IERC20 public immutable underlyingToken;
  IReceiptToken public immutable receiptToken;

  uint256 public immutable DECIMAL_FACTOR;

  constructor(address _admin, IERC20 _underlyingToken, IReceiptToken _receiptToken) {
    _grantRole(DEFAULT_ADMIN_ROLE, _admin);

    underlyingToken = _underlyingToken;
    receiptToken = _receiptToken;

    DECIMAL_FACTOR = 10 ** (18 - IERC20Metadata(address(underlyingToken)).decimals());
  }

  function withdraw(address _to, uint256 _amount) external onlyRole(MANAGER) {
    underlyingToken.transfer(_to, _amount);
  }

  function mint(address _to, uint256 _underlyingAmount) external {
    uint256 balance = underlyingToken.balanceOf(address(this));

    underlyingToken.transferFrom(msg.sender, address(this), _underlyingAmount);

    uint256 underlyingAmountReceived = underlyingToken.balanceOf(address(this)) - balance;

    receiptToken.mint(_to, underlyingAmountReceived * DECIMAL_FACTOR);
  }

  function redeem(address _to, uint256 _receiptAmount) external {
    receiptToken.burnFrom(msg.sender, _receiptAmount * DECIMAL_FACTOR);
    
    underlyingToken.transfer(_to, _receiptAmount * DECIMAL_FACTOR);
  }
}
