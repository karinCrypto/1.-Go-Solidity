// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 배열과 매핑 예제
contract ArraysMapping {
    // 배열
    uint256[] public numbers;

    // 매핑: key → value
    mapping(address => uint256) public balances;

    function addNumber(uint256 _num) public {
        numbers.push(_num);
    }

    function setBalance(uint256 _amount) public {
        balances[msg.sender] = _amount;
    }
}
