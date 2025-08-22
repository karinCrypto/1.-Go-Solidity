# Hardhat Development Setup

이 프로젝트는 [Hardhat](https://hardhat.org/) 기반 스마트 컨트랙트 개발 환경을 사용합니다.  
⚠️ **Node.js 18 이상**이 필요합니다. (Node 16.x 이하에서는 설치가 실패할 수 있음)

---

## 🚀 Node.js 버전 업그레이드 (Mac/Linux)
```bash
1. nvm 설치 여부 확인
command -v nvm

2. nvm 설치 (설치 안 되어 있다면)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

터미널 환경 다시 로드:
source ~/.zshrc   # Mac 기본(zsh) 환경
또는
source ~/.bashrc  # bash 환경

3. Node.js 18 설치 및 적용
nvm install 18          # Node 18 설치
nvm use 18              # 현재 세션에서 Node 18 사용
nvm alias default 18    # 기본 버전을 Node 18로 고정

4. 확인
node -v
npm -v
👉 v18.x.x 이상이 나오면 성공!

💻 Hardhat 설치 및 실행
프로젝트 의존성 설치
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox

Hardhat 초기화
npx hardhat
✅ 실행 후, Create a JavaScript project 선택 → 환경 세팅 완료.

📌 Troubleshooting
EBADENGINE 관련 오류 발생 시:
Node.js 버전이 낮아서 발생하는 문제
반드시 Node.js 18 이상으로 업그레이드 필요


# 1.-Go-Solidity
solidity-basics/
├── 01-hello-world/
├── 02-variables-and-types/
├── 03-control-structures/
├── 04-arrays-mapping/
├── 05-struct-enum/
├── 06-modifiers/
├── 07-inheritance-interface/
├── 08-events-logging/
└── test/ (하드햇 테스트 예시)
