// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Hello World 예제
/// @notice 가장 기본적인 스마트 컨트랙트 예제
contract HelloWorld {
    string public message = "Hello, Solidity!";

    // 상태 변경 함수
    function setMessage(string memory _msg) public {
        message = _msg;
    }
}
