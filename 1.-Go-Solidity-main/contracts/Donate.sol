// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title Donate - 투명한 기부 관리 스마트컨트랙트
/// @notice 기부 내역을 온체인에 기록하고, 관리자만 인출할 수 있음
contract Donate {
    // 📌 상태 변수
    address public admin;                // 관리자 주소
    uint256 public totalDonations;       // 총 기부금 누적
    uint256 public currentBalance;       // 현재 보관 중인 기부금 잔액

    // 📌 기부 내역 구조체
    struct Donation {
        address donor;       // 기부자 주소
        uint256 amount;      // 기부 금액
        uint256 timestamp;   // 기부 시각 (block.timestamp)
    }

    // 📌 모든 기부 내역 저장
    Donation[] public donations;

    // 📌 이벤트
    event Donated(address indexed donor, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed admin, uint256 amount, uint256 timestamp);

    // 📌 생성자: 관리자 지정
    constructor(address _admin) {
        require(_admin != address(0), "Invalid admin address");
        admin = _admin;
    }

    // 📌 기부 함수 (receive와 별도 함수 둘 다 지원)
    receive() external payable {
        donate();
    }

    function donate() public payable {
        require(msg.value > 0, "Donation must be greater than 0");

        // 기부 내역 저장
        donations.push(Donation(msg.sender, msg.value, block.timestamp));

        // 총액 업데이트
        totalDonations += msg.value;
        currentBalance += msg.value;

        emit Donated(msg.sender, msg.value, block.timestamp);
    }

    // 📌 인출 함수 (관리자만)
    function withdraw(uint256 _amount, address payable _to) external {
        require(msg.sender == admin, "Only admin can withdraw");
        require(_amount <= currentBalance, "Insufficient balance");
        require(_to != address(0), "Invalid recipient");

        currentBalance -= _amount;
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Withdrawal failed");

        emit Withdrawn(msg.sender, _amount, block.timestamp);
    }

    // 📌 기부 내역 개수 조회
    function getDonationCount() external view returns (uint256) {
        return donations.length;
    }

    // 📌 특정 기부 내역 조회
    function getDonation(uint256 _index) external view returns (address, uint256, uint256) {
        require(_index < donations.length, "Invalid index");
        Donation memory d = donations[_index];
        return (d.donor, d.amount, d.timestamp);
    }
}
