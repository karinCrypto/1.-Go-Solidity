// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// 입금 & 출금 로직 (조건문 + require + revert)

contract Bank {
    mapping(address => uint) public balances;

    // 입금 함수
    function deposit() public payable {
        require(msg.value > 0, "Must send ETH"); // 조건 검증
        balances[msg.sender] += msg.value;
    }

    // 출금 함수
    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance");

        balances[msg.sender] -= amount;

        // 실제 전송 (실패 시 자동 revert)
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            revert("ETH transfer failed"); // 명시적 revert
        }
    }
}
//require() → 입금 금액/출금 가능 여부 체크
//revert() → 전송 실패 시 명시적으로 중단
