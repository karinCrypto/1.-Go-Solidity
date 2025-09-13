// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; 

contract MyContract {
    // 상태 변수들 (storage에 저장됨)
    uint public count = 0;          // 숫자형 상태 변수
    string public name = "Karin";   // 문자열 상태 변수
    address public owner;           // 주소 상태 변수
    bool public isActive = true;    // 불리언 상태 변수

    constructor() {
        owner = msg.sender;         // 배포자 주소 기록
    }

    function increment() public {
        count += 1;                 // 상태 변수 업데이트 (storage 기록)
    }
}
