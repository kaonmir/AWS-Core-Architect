# AWS Core Architect (ACA)

## 1. Simple Express Server

EC2에서 `npm start`를 하면 서버가 Express 서버가 실행된다. NGINX를 쓰지 않고도 외부에서 이 서버에 접속할 수 있을까?

### 1.1. VPC & EC2 구성

새로 VPC를 만들고 Public 서브넷 (A)과 Private Subnet (B)를 만든다.

1. `A-Host`로 이름 지은 EC2를 생성하고 Express를 실행한다. (A 서브넷에 둔다.)
2. `A-Sub` EC2를 생성하고 테스트한다. (A-Host와 같은 서브넷에 둔다.)
3. `B-Sub` EC2를 이번에는 (B 서브넷에 둔다.)

A-Host는 Security Group에서 Inbound에 3000 포트도 추가로 연다.

### 1.2. Express 구성

간단하게 `/health`로 HTTP GET 요청을 하면 `{status: "ok"}`을 반환하게 하는 API를 만들어보자. `install.sh` 파일을 만들어 놓았으니 저거 가져다가 쓰자.

![Simple Express Server Diagram](Assets/1.%20simple%20express%20server%20diagram.png)

### 1.3. 결과 확인하기

- [X] `A-Host`에서 Localhost로 확인한다.
- [X] `A-Host`에서 ssh를 끊었다가 다시 연결한 다음, Localhost로 확인한다.
- [X] `A-Sub`에서 `A-Host`의 Private IP로 확인한다. 
- [X] `B-Sub`에서 `A-Host`의 Private IP로 확인한다.
- [X] 로컬 컴퓨터에서 `A-Host`의 Public IP로 확인한다.

### 1.4. 결론

따로 NGINX를 쓰지 않고 `npm start`만 해도 포트는 외부에 노출된다.


## 2. 간단한 ELB 구축

아까 만든 VPC에서 ALB를 통해 Private 서브넷에 있는 Target Group에 접근하는 작업을 해보자

![](Assets/2.%20simple%20ELB.png)

### 2.1. 서브넷에 똑같은 EC2 두 개 만들기

이번 작업은 ASG나 시작 템플릿 같은 자동화 도구를 쓰지 않고 진행할 거다. 모두 수동으로 각각의 인스턴스를 만들고 Bastion Host를 통해 ssh로 접근한다. 각 EC2에 이전에 만들었던 Express 서버를 설치하고 잘 동작하는지 다시 한 번 검사한다. 인터넷이 안된다면 NAT Gateway가 동작하지 않는 것이니 확인하자.

### 2.2. EC2를 Target Group에 넣고 ALB 붙이기

이 작업은 모두 콘솔에서 진행한다. 3000번 포트로 대상 그룹과 ALB를 만든다. 그리고 ALB에서 자체 제공해 주는 도메인 네임으로 접근을 해본다.

### 2.3. 문제 발생

이유는 모르겠지만 한 번 `curl`을 던졌을 때는 잘 동작하는 데 다시 한 번 던지면 timeout이 나온다. EC2 하나가 불량인가 싶어 각자의 Private IP로도 던졌는데 잘 된다. 혹시나 해서 EC2 하나를 가지고도 실험해 봤는데 같은 결과가 나왔다.

![Why doesn't it work](Assets/2.1.%20elb%20went%20worng.gif)


## 3. CI/CD Pipeline 구축

이번에는 Code Series를 이용해서 EC2를 배포해보는 작업을 할 거다.

복잡성을 덜어내고자 ASG나 DB 연결 같은 부분은 제외했고 기본적인 것들로만 구성했다. VPC와 서비넷은 기존의 것들을 활용하면 된다.

![CI/CD Code Pipeline](Assets/3.%20cicd%20pipeline.png)

### 3.1. VPC 구성 요소 추가

위 사진에서 코드 파이프라인 부분을 제외하고 구축한다. Target Group의 EC2 2개는 직접 콘솔로 만들어 넣어 둘 거고, 코드는 이전에 만들었던 /health API가 있는 Express를 활용할 것이다.

EC2가 모두 Private 서브넷에 있기 때문에 NAT 게이트웨이를 만들고 라우트 테이블을 변경해서 단방향 통신이 가능하게 한다.

### 3.2. CI/CD 파이프라인 구축

깃허브에 커밋이 되면 자동으로 새 EC2를 만들어서 Target Group에 추가하도록 구성해보자. 커밋을 10번 하면 10개의 EC2가 추가되는 건데 말이 안되긴 한다. 그래도 일단 그렇게 하고 나중에 ASG를 통해서 관리하자.