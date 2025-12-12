// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {PSMSetupTest} from "./Setup.sol";

import {EventsLib} from "../src/libraries/EventsLib.sol";

contract PSMMintTest is PSMSetupTest {
  function test_mint_successful(uint256 _underlyingAmount, address _to) public {
    vm.assume(_to != address(0) && _to != address(psm) && _to != address(this));
    _underlyingAmount = bound(_underlyingAmount, 0, TRILLION * 10 ** underlyingToken.decimals());

    deal(address(underlyingToken), address(this), _underlyingAmount, true);

    underlyingToken.approve(address(psm), _underlyingAmount);

    uint256 expectedReceiptAmount = _underlyingAmount * psm.DECIMAL_FACTOR();

    vm.expectEmit(true, true, true, true);
    emit EventsLib.Mint(address(this), _to, _underlyingAmount, expectedReceiptAmount, block.timestamp);
    uint256 actualReceiptAmount = psm.mint(_to, _underlyingAmount);

    assertEq(actualReceiptAmount, expectedReceiptAmount);

    assertEq(receiptToken.balanceOf(_to), expectedReceiptAmount);
    assertEq(receiptToken.balanceOf(address(this)), 0);
    assertEq(receiptToken.balanceOf(address(psm)), 0);
    assertEq(receiptToken.totalSupply(), expectedReceiptAmount);

    assertEq(underlyingToken.balanceOf(address(this)), 0);
    assertEq(underlyingToken.balanceOf(address(psm)), INITIAL_UNDERLYING_BALANCE + _underlyingAmount);
    assertEq(underlyingToken.balanceOf(_to), 0);
  }
}
