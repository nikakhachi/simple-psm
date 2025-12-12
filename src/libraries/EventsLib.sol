// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library EventsLib {
  event Withdraw(address indexed caller, address indexed to, uint256 underlyingAmount, uint256 timestamp);

  event Mint(
    address indexed from,
    address indexed to,
    uint256 underlyingAmount,
    uint256 receiptAmount,
    uint256 timestamp
  );

  event Redeem(
    address indexed from,
    address indexed to,
    uint256 underlyingAmount,
    uint256 receiptAmount,
    uint256 timestamp
  );
}
