// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// Hardhat 환경에서 콘솔 출력용 (테스트 시 로그 확인 가능)
import "hardhat/console.sol";

/**
 * @title Owner
 * @dev 컨트랙트의 소유자를 설정하고 변경할 수 있는 간단한 예제
 */
contract Owner {

    // 현재 컨트랙트 소유자 주소 (private: 외부 직접 접근 불가)
    address private owner;

    // 소유자가 변경될 때마다 발생하는 이벤트
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // ---- 접근 제어 ----
    /**
     * @dev 이 컨트랙트를 호출하는 주체가 현재 소유자인지 검사하는 제어자
     * - 조건을 만족하지 못하면 트랜잭션을 revert(취소)한다.
     */
    modifier isOwner() {
        // require 조건이 false이면 실행이 중단되고 상태 변경이 모두 되돌려진다.
        // 과거 EVM에서는 모든 가스를 소모했지만 지금은 그렇지 않다.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    // ---- 생성자 ----
    /**
     * @dev 컨트랙트 배포 시 실행
     * - 컨트랙트 배포자를 최초 소유자로 등록한다.
     */
    constructor() {
        console.log("Owner contract deployed by:", msg.sender);
        // msg.sender : 현재 호출 주체 (생성자에서는 배포자 주소)
        owner = msg.sender;
        emit OwnerSet(address(0), owner); // 초기 소유자 설정 이벤트 발생
    }

    // ---- 함수 ----
    /**
     * @dev 현재 소유자가 새 소유자를 지정
     * @param newOwner 새 소유자로 지정할 주소
     */
    function changeOwner(address newOwner) public isOwner {
        // 새 소유자가 0 주소(없음)가 아닌지 확인
        require(newOwner != address(0), "New owner should not be the zero address");
        emit OwnerSet(owner, newOwner); // 소유자 변경 이벤트 발생
        owner = newOwner;               // 소유자 주소 변경
    }

    /**
     * @dev 현재 소유자 주소를 조회
     * @return 현재 소유자의 주소
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}
