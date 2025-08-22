// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 조건문, 반복문 예제
contract ControlStructures {
    uint256 public total;

    // if-else 예제
    function checkNumber(uint256 _num) public pure returns (string memory) {
        if (_num % 2 == 0) {
            return "Even number";
        } else {
            return "Odd number";
        }
    }

    // for 반복문 예제
    function sumNumbers(uint256 n) public returns (uint256) {
        total = 0;
        for (uint256 i = 1; i <= n; i++) {
            total += i;
        }
        return total;
    }
}
