// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 구조체와 열거형 예제
contract StructEnum {
    // Enum 선언
    enum Status { Pending, Shipped, Delivered }

    // Struct 선언
    struct Order {
        uint256 id;
        string product;
        Status status;
    }

    // 주문 저장
    Order[] public orders;

    function createOrder(string memory _product) public {
        orders.push(Order(orders.length, _product, Status.Pending));
    }

    function shipOrder(uint256 _id) public {
        orders[_id].status = Status.Shipped;
    }
}
