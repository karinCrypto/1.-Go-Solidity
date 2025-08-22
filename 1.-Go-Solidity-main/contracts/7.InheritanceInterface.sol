// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 상속과 인터페이스 예제

// 부모 컨트랙트
contract Animal {
    string public sound;

    function makeSound() public virtual {
        sound = "Some sound";
    }
}

// 자식 컨트랙트
contract Dog is Animal {
    function makeSound() public override {
        sound = "Woof!";
    }
}

// 인터페이스
interface ICalculator {
    function add(uint256 a, uint256 b) external pure returns (uint256);
}

// 인터페이스 구현
contract Calculator is ICalculator {
    function add(uint256 a, uint256 b) external pure override returns (uint256) {
        return a + b;
    }
}
