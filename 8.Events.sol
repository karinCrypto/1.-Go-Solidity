// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 이벤트와 로그 예제
contract Events {
    event ValueChanged(address indexed user, uint256 newValue);

    uint256 public value;

    function setValue(uint256 _val) public {
        value = _val;
        emit ValueChanged(msg.sender, _val); // 이벤트 발생
    }
}
