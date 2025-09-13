// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VisibilityExample
 * @dev 함수의 가시성(public / private / internal / external) 차이를 설명하는 실습 예제
 */
contract VisibilityExample {
    // public 상태 변수: 자동으로 getter 함수가 생성됨
    uint public count = 0;

    // 1. public : 어디서나 접근 가능 (내부·외부 모두 가능)
    function inc() public {
        count += 1;
    }

    // 2. private : 이 컨트랙트 내부에서만 호출 가능
    function _double() private {
        count *= 2;
    }

    // 3. internal : 이 컨트랙트와 상속받은 컨트랙트에서 접근 가능
    function _triple() internal {
        count *= 3;
    }

    // 4. external : 외부에서만 직접 호출 가능
    //    내부에서 호출하려면 this.reset()처럼 this를 붙여야 함
    function reset() external {
        count = 0;
    }

    // 내부에서 external 함수를 호출하는 예시
    function callReset() public {
        this.reset(); // this를 붙여야 external 함수 호출 가능
    }

    // private 함수를 내부에서만 실행하도록 별도 래퍼 함수
    function doubleCall() public {
        _double();
    }
}

/**
 * @title Child
 * @dev VisibilityExample을 상속받아 internal 함수 접근을 실습
 */
contract Child is VisibilityExample {
    function tripleCall() public {
        _triple(); // internal 함수는 상속받은 자식 컨트랙트에서 호출 가능
    }
}
