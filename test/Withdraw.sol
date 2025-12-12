// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {PSMSetupTest} from "./Setup.sol";

import {IAccessControl} from "openzeppelin-contracts/contracts/access/IAccessControl.sol";

import {EventsLib} from "../src/libraries/EventsLib.sol";

contract PSMWithdrawTest is PSMSetupTest {
  function test_withdraw_successful(uint256 _amount, address _to) public {
    vm.assume(_to != address(0) && _to != address(psm));

    _amount = bound(_amount, 0, INITIAL_UNDERLYING_BALANCE);

    vm.startPrank(manager);

    vm.expectEmit(true, true, true, true);
    emit EventsLib.Withdraw(manager, _to, _amount, block.timestamp);
    psm.withdraw(_to, _amount);

    assertEq(underlyingToken.balanceOf(_to), _amount);
    assertEq(underlyingToken.balanceOf(address(psm)), INITIAL_UNDERLYING_BALANCE - _amount);
  }

  function test_withdraw_unauthorized(address _caller, uint256 _amount) public {
    vm.assume(_caller != manager);

    vm.startPrank(_caller);

    vm.expectRevert(
      abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, _caller, psm.MANAGER())
    );
    psm.withdraw(_caller, _amount);
  }
}
