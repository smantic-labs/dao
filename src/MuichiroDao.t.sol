// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./MuichiroDao.sol";

contract MuichiroDaoTest is DSTest {
    MuichiroDao dao;

    function setUp() public {
        dao = new MuichiroDao(payable(address(0)));
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
