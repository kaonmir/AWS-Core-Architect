# AWS Core Architect


## 1. Simple Express Server

EC2에서 `npm start`를 하면 서버가 Express 서버가 실행된다. 그러면 외부에서 이 서버를 접속할 수 있을까?

> 직접해보면 된다.

### EC2 구성

1. `A-Host`로 이름 지은 EC2를 생성하고 Express를 실행한다. (Default VPC에서 us-east-2a AZ에 있는 서브넷에 둔다.)
1. `A-Sub` EC2를 생성하고 테스트한다. (A-Host와 같은 서브넷에 둔다.)
1. `B-Sub` EC2를 이번에는 (Default VPC에서 us-east-2b에 있는 서브넷에 둔다.)

### Express 구성

간단하게 `/health`에 GET HTTP 요청을 하면 `{status: "ok"}`을 반환하게 하는 API를 만들어보자
