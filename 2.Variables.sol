// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 변수와 자료형 실습
contract Variables {
    // 기본 자료형
    bool public isActive = true;
    uint256 public count = 42;
    int256 public signedNumber = -10;
    address public owner;
    bytes32 public hashValue = keccak256(abi.encodePacked("Solidity"));

    constructor() {
        owner = msg.sender; // 배포자 주소 저장
    }

    // 값 변경 함수
    function setCount(uint256 _count) public {
        count = _count;
    }
}
