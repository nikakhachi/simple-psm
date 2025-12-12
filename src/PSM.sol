// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IReceiptToken} from "./interfaces/IReceiptToken.sol";

import {EventsLib} from "./libraries/EventsLib.sol";

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

    emit EventsLib.Withdraw(msg.sender, _to, _amount, block.timestamp);
  }

  function mint(address _to, uint256 _underlyingAmount) external returns (uint256 _receiptAmount) {
    uint256 balance = underlyingToken.balanceOf(address(this));

    underlyingToken.transferFrom(msg.sender, address(this), _underlyingAmount);

    uint256 underlyingAmountReceived = underlyingToken.balanceOf(address(this)) - balance;

    _receiptAmount = underlyingAmountReceived * DECIMAL_FACTOR;

    receiptToken.mint(_to, _receiptAmount);

    emit EventsLib.Mint(msg.sender, _to, _underlyingAmount, _receiptAmount, block.timestamp);
  }

  function redeem(address _to, uint256 _underlyingAmount) external returns (uint256 _receiptAmount) {
    _receiptAmount = _underlyingAmount * DECIMAL_FACTOR;

    receiptToken.burnFrom(msg.sender, _receiptAmount);

    underlyingToken.transfer(_to, _underlyingAmount);

    emit EventsLib.Redeem(msg.sender, _to, _underlyingAmount, _receiptAmount, block.timestamp);
  }
}
