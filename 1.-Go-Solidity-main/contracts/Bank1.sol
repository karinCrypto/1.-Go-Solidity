// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title Bank1 - 간단한 지갑 컨트랙트
/// @notice 자금을 안전하게 관리하고, 소유자만 송금/소유자 변경 가능
contract Bank1 {
    // 상태 변수
    address public owner; // 컨트랙트의 소유자 주소

    // 이벤트 (event)
    event FundsReceived(address indexed from, uint256 amount); // 입금 발생 시
    event FundsSent(address indexed to, uint256 amount);       // 출금 발생 시
    event OwnerChanged(address indexed oldOwner, address indexed newOwner); // 소유자 변경 시

    // 생성자 (constructor)
    /// @param _owner 컨트랙트 최초 소유자
    constructor(address _owner) {
        require(_owner != address(0), "Invalid owner address");
        owner = _owner;
    }

    // receive 함수: 외부에서 ETH를 받을 때 자동 실행됨
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    // 송금 함수 (sendFunds)
    /// @notice 오직 소유자만 자금을 특정 주소로 보낼 수 있음
    /// @param _to 수신자 주소
    /// @param _amount 송금 금액 (wei 단위)
    function sendFunds(address payable _to, uint256 _amount) external {
        require(msg.sender == owner, "Only owner can send funds"); // 권한 체크
        require(address(this).balance >= _amount, "Insufficient balance"); // 잔액 체크

        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");

        emit FundsSent(_to, _amount);
    }

    // 소유자 변경 함수(changeOwner)
    /// @notice 오직 현재 소유자만 새로운 소유자를 설정 가능
    /// @param _newOwner 새로운 소유자 주소
    function changeOwner(address _newOwner) external {
        require(msg.sender == owner, "Only owner can change ownership"); // 권한 체크
        require(_newOwner != address(0), "Invalid new owner"); // 잘못된 주소 방지

        address oldOwner = owner;
        owner = _newOwner;

        emit OwnerChanged(oldOwner, _newOwner);
    }

    // 조회 함수: 컨트랙트 보유 ETH 잔액 확인 (view)
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
