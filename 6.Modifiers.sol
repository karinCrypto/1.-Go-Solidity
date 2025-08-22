// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 모디파이어 예제
contract Modifiers {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // onlyOwner 모디파이어
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner!");
        _;
    }

    uint256 public value;

    function setValue(uint256 _val) public onlyOwner {
        value = _val;
    }
}
