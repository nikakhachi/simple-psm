// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {PSMSetupTest} from "./Setup.sol";

import {EventsLib} from "../src/libraries/EventsLib.sol";

import {IERC20Errors} from "openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";

contract PSMRedeemTest is PSMSetupTest {
  function test_redeem_successful(uint256 _underlyingAmount, address _to) public {
    vm.assume(_to != address(0) && _to != address(psm) && _to != address(this));

    _underlyingAmount = bound(_underlyingAmount, 0, INITIAL_UNDERLYING_BALANCE);

    uint256 _receiptAmount = _underlyingAmount * psm.DECIMAL_FACTOR();

    deal(address(receiptToken), address(this), _receiptAmount, true);

    receiptToken.approve(address(psm), _receiptAmount);

    vm.expectEmit(true, true, true, true);
    emit EventsLib.Redeem(address(this), _to, _underlyingAmount, _receiptAmount, block.timestamp);
    uint256 actualReceiptAmount = psm.redeem(_to, _underlyingAmount);

    assertEq(actualReceiptAmount, _receiptAmount);

    assertEq(receiptToken.balanceOf(address(this)), 0);
    assertEq(receiptToken.balanceOf(address(psm)), 0);
    assertEq(receiptToken.totalSupply(), 0);
  }

  function test_redeem_illiquid(uint256 _underlyingAmount, address _to) public {
    vm.assume(_to != address(0) && _to != address(psm) && _to != address(this));

    _underlyingAmount = bound(
      _underlyingAmount,
      INITIAL_UNDERLYING_BALANCE + 1,
      TRILLION * 10 ** underlyingToken.decimals()
    );

    uint256 _receiptAmount = _underlyingAmount * psm.DECIMAL_FACTOR();

    deal(address(receiptToken), address(this), _receiptAmount, true);

    receiptToken.approve(address(psm), _receiptAmount);

    vm.expectRevert(
      abi.encodeWithSelector(
        IERC20Errors.ERC20InsufficientBalance.selector,
        address(psm),
        INITIAL_UNDERLYING_BALANCE,
        _underlyingAmount
      )
    );
    psm.redeem(_to, _underlyingAmount);
  }
}
