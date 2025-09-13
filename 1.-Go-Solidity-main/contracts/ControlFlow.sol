
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract LoopExample {
    uint[] public numbers;

    function fillNumbers() public {
        for (uint i = 1; i <= 10; i++) {
            if (i == 5) {
                continue; // i == 5일 때는 아래 코드 실행 안 하고 다음 반복
            }
            if (i == 9) {
                break; // 9에서 멈춤
            }
            numbers.push(i);
        }
    }

    function getNumber(uint index) public view returns (uint) {
        // 내부 검증: index 범위 확인
        assert(index < numbers.length);  
        return numbers[index];
    }
}
