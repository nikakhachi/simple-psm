// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {PSM} from "../src/PSM.sol";
import {MockedUnderlyingToken} from "./mocks/MockedUnderlyingToken.sol";
import {MockedReceiptToken} from "./mocks/MockedReceiptToken.sol";

import {IReceiptToken} from "../src/interfaces/IReceiptToken.sol";
import {Test} from "forge-std/Test.sol";

contract PSMSetupTest is Test {
  PSM public psm;

  address public admin = makeAddr("admin");
  address public manager = makeAddr("manager");
  address public user = makeAddr("user");

  MockedUnderlyingToken public underlyingToken;
  MockedReceiptToken public receiptToken;

  uint256 public constant INITIAL_UNDERLYING_BALANCE = 1_000_000e18;
  uint256 public constant TRILLION = 1_000_000_000_000_000_000_000_000;

  function setUp() public {
    underlyingToken = new MockedUnderlyingToken();
    receiptToken = new MockedReceiptToken();

    psm = new PSM(admin, underlyingToken, IReceiptToken(address(receiptToken)));

    bytes32 MANAGER_ROLE = psm.MANAGER();

    vm.prank(admin);
    psm.grantRole(MANAGER_ROLE, manager);

    deal(address(underlyingToken), address(psm), INITIAL_UNDERLYING_BALANCE, true);
  }
}
