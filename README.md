# AWS Core Architect (ACA)

## 1. Simple Express Server

EC2에서 `npm start`를 하면 서버가 Express 서버가 실행된다. 그러면 외부에서 이 서버를 접속할 수 있을까?

> 직접해보면 된다.

### VPC & EC2 구성

새로 VPC를 만들고 Public 서브넷 (A)과 Private Subnet (B)를 만든다.

1. `A-Host`로 이름 지은 EC2를 생성하고 Express를 실행한다. (A 서브넷에 둔다.)
2. `A-Sub` EC2를 생성하고 테스트한다. (A-Host와 같은 서브넷에 둔다.)
3. `B-Sub` EC2를 이번에는 (B 서브넷에 둔다.)

A-Host는 Security Group에서 Inbound에 3000 포트도 추가로 연다.

### Express 구성

간단하게 `/health`로 HTTP GET 요청을 하면 `{status: "ok"}`을 반환하게 하는 API를 만들어보자

``` bash
# Amazon Linux 2에 npm 설치하기 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node

# ssh를 종료해도 node 실행시키기
nohup npm start &

# A-Host에서 /health 확인하기
curl http://localhost:3000/health
```
### 결과 확인하기
확인 방법은 다음과 같다.

1. `A-Host`에서 Localhost로 확인을 해 본 다음 잘 되면 ssh를 끊었다가 다시 해본다.
2. `A-Sub`에서 `A-Host`의 Private IP로 확인한다. 
3. `B-Sub`에서 `A-Host`의 Private IP로 확인한다.
4. 로컬 컴퓨터에서 `A-Host`의 Public IP로 확인한다.


