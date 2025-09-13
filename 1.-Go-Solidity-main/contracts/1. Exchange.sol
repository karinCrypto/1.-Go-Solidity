// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.20; // Solidity 버전 고정 (0.8.20)

// 📌 Hardhat 콘솔 - 디버깅 용도 (배포/테스트 시 console.log 사용 가능)
import "hardhat/console.sol";

// 📌 ERC20 인터페이스 및 구현체 (토큰과 교환하기 위함)
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 📌 외부 컨트랙트와 연결하기 위한 인터페이스
import "./interfaces/IFactory.sol";
import "./interfaces/IExchange.sol";

/// @title 간단한 Uniswap V2 스타일 교환소 (AMM)
/// @notice ETH와 특정 ERC20 토큰 간 교환 및 유동성 공급 기능 제공
contract Exchange is ERC20 {
    // =======================
    // 📢 이벤트 정의
    // =======================
    event TokenPurchase(address indexed buyer, uint256 ethSold, uint256 tokensBought); // ETH → Token
    event EthPurchase(address indexed buyer, uint256 tokensSold, uint256 ethBought);   // Token → ETH
    event AddLiquidity(address indexed provider, uint256 ethAmount, uint256 tokenAmount); // 유동성 공급
    event RemoveLiquidity(address indexed provider, uint256 ethAmount, uint256 tokenAmount); // 유동성 제거

    // =======================
    // 📌 상태 변수
    // =======================
    IERC20 public token;     // 교환 대상 ERC20 토큰
    IFactory public factory; // 교환소를 생성한 팩토리 컨트랙트 주소

    // =======================
    // 📌 생성자
    // =======================
    /// @param _token 교환할 ERC20 토큰 주소
    constructor(address _token) ERC20("Gray Uniswap V2", "GUNI-V2") {
        require(_token != address(0), "Invalid token address"); // 0 주소 방지
        token = IERC20(_token);
        factory = IFactory(msg.sender); // 배포자는 팩토리로 설정
    }

    // =======================
    // 📌 유동성 공급
    // =======================
    /// @notice ETH와 토큰을 풀에 예치하고 LP 토큰 발행
    /// @param _maxTokens 공급자가 예치할 수 있는 최대 토큰 양
    /// @return 발행된 유동성 토큰 양
    function addLiquidity(uint256 _maxTokens) public payable returns (uint256) {
        require(_maxTokens > 0 && msg.value > 0, "Invalid amounts"); // 0 예치 방지
        uint256 totalLiquidity = totalSupply(); // 현재 풀의 전체 유동성 (LP 토큰 총량)

        if (totalLiquidity > 0) {
            // 📌 기존 풀에 유동성 추가
            uint256 ethReserve = address(this).balance - msg.value; // 기존 ETH 풀
            uint256 tokenReserve = token.balanceOf(address(this));   // 기존 토큰 풀
            uint256 tokenAmount = (msg.value * tokenReserve) / ethReserve; // 필요한 토큰 양 계산

            require(_maxTokens >= tokenAmount, "Too few tokens provided");
            require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");

            uint256 liquidityMinted = (totalLiquidity * msg.value) / ethReserve; // 신규 발행될 LP 토큰
            _mint(msg.sender, liquidityMinted);

            emit AddLiquidity(msg.sender, msg.value, tokenAmount);
            return liquidityMinted;
        } else {
            // 📌 최초 유동성 공급 (풀 생성 시점)
            require(msg.value > 1 gwei, "ETH too small"); // 최소 예치 조건
            uint256 tokenAmount = _maxTokens;             // 첫 공급자는 원하는 만큼 예치 가능
            uint256 initialLiquidity = address(this).balance; // 초기 유동성 = 예치 ETH

            _mint(msg.sender, initialLiquidity); // 초기 공급자에게 LP 발행
            require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");

            emit AddLiquidity(msg.sender, msg.value, tokenAmount);
            return initialLiquidity;
        }
    }

    // =======================
    // 📌 유동성 제거
    // =======================
    /// @notice LP 토큰을 소각하고 비율만큼 ETH + 토큰을 반환
    /// @param _lpToken 반환할 LP 토큰 양
    /// @return 반환된 (ETH 양, 토큰 양)
    function removeLiquidity(uint256 _lpToken) public returns (uint256, uint256) {
        uint256 totalLiquidity = totalSupply();
        require(_lpToken > 0 && totalLiquidity > 0, "Invalid liquidity amount");

        // 비율에 맞게 ETH와 토큰 양 계산
        uint256 ethAmount = (_lpToken * address(this).balance) / totalLiquidity;
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 tokenAmount = (_lpToken * tokenReserve) / totalLiquidity;

        _burn(msg.sender, _lpToken); // LP 소각

        payable(msg.sender).transfer(ethAmount); // ETH 반환
        require(token.transfer(msg.sender, tokenAmount), "Token transfer failed"); // 토큰 반환

        emit RemoveLiquidity(msg.sender, ethAmount, tokenAmount);
        return (ethAmount, tokenAmount);
    }

    // =======================
    // 📌 Swap 기능
    // =======================

    /// @notice ETH → Token 스왑 (자기 자신에게 전송)
    /// @param _minTokens 최소 수령 토큰 양 (슬리피지 방지)
    function ethToTokenSwap(uint256 _minTokens) public payable {
        ethToToken(_minTokens, msg.sender);
    }

    /// @notice ETH → Token 스왑 (지정한 수신자에게 전송)
    /// @param _minTokens 최소 수령 토큰 양
    /// @param _recipient 토큰 수령자
    function ethToTokenTransfer(uint256 _minTokens, address _recipient) public payable {
        ethToToken(_minTokens, _recipient);
    }

    /// @notice Token → ETH 스왑
    /// @param _tokenSold 판매할 토큰 양
    /// @param _minEth 최소 수령 ETH 양
    function tokenToEthSwap(uint256 _tokenSold, uint256 _minEth) public {
        uint256 outputAmount = getOutputAmount(
            _tokenSold,
            token.balanceOf(address(this)),
            address(this).balance
        );
        require(outputAmount >= _minEth, "Insufficient ETH output");

        payable(msg.sender).transfer(outputAmount); // ETH 전송
        require(token.transferFrom(msg.sender, address(this), _tokenSold), "Token transfer failed");

        emit EthPurchase(msg.sender, _tokenSold, outputAmount);
    }

    /// @notice Token → 다른 Token 스왑
    /// @param _tokenSold 판매할 토큰 양
    /// @param _minTokenBought 최소 수령 토큰 양
    /// @param _minEthBought 중간 ETH 최소 수령 양
    /// @param _tokenAddress 교환할 다른 토큰 주소
    function tokenToTokenSwap(
        uint256 _tokenSold,
        uint256 _minTokenBought,
        uint256 _minEthBought,
        address _tokenAddress
    ) public {
        address toTokenExchangeAddress = factory.getExchange(_tokenAddress);

        // 📌 Step1: Token → ETH 변환
        uint256 ethOutputAmount = getOutputAmount(
            _tokenSold,
            token.balanceOf(address(this)),
            address(this).balance
        );
        require(_minEthBought <= ethOutputAmount, "Insufficient ETH output");

        require(token.transferFrom(msg.sender, address(this), _tokenSold), "Token transfer failed");

        // 📌 Step2: ETH → 대상 토큰 변환
        IExchange(toTokenExchangeAddress).ethToTokenTransfer{value: ethOutputAmount}(
            _minTokenBought,
            msg.sender
        );
    }

    // =======================
    // 📌 내부 로직
    // =======================

    /// @dev ETH → Token 변환 내부 처리
    function ethToToken(uint256 _minTokens, address _recipient) private {
        uint256 tokenReserve = token.balanceOf(address(this));

        // 출력 토큰 양 계산
        uint256 outputAmount = getOutputAmount(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );
        require(outputAmount >= _minTokens, "Insufficient token output");

        require(token.transfer(_recipient, outputAmount), "Token transfer failed");

        emit TokenPurchase(_recipient, msg.value, outputAmount);
    }

    // =======================
    // 📌 가격 계산 함수
    // =======================

    /// @notice Uniswap 수식 (수수료 포함) x * y = k
    function getOutputAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Invalid reserves");
        uint256 inputAmountWithFee = inputAmount * 99; // 1% 수수료
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;
        return numerator / denominator;
    }

    /// @notice Uniswap 수식 (수수료 없음)
    function getOutputAmountNoFee(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Invalid reserves");
        uint256 numerator = inputAmount * outputReserve;
        uint256 denominator = inputReserve + inputAmount;
        return numerator / denominator;
    }

    // =======================
    // 📌 조회 함수
    // =======================

    /// @notice 컨트랙트 ETH 잔액 반환
    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
