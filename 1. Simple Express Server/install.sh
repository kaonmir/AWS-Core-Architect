#!/bin/sh

# Update & Upgrade
sudo yum update -y
sudo yum upgrade -y

# Amazon Linux 2에 npm 설치하기 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node

# Git 설치 후 리포지토리 다운로드
sudo yum install -y git
git clone https://github.com/kaonmir/AWS-Core-Architect

# 의존성 설치 후 서버 실행
cd AWS-CORE-ARCHITECT/1. Simple Express Server
npm install
nohup npm start & # ssh를 종료해도 node 실행시키기
clear

# A-Host에서 /health 확인하기
curl http://localhost:3000/health