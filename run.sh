#!/bin/bash

# LightRAG 서버 시작 스크립트 (Unix/Linux/macOS)
set -e

echo "🚀 LightRAG 서버 시작 중..."

# 환경 설정 파일 복사
if [ ! -f ".env" ]; then
    echo "📋 환경 설정 파일 생성 중..."
    cp env.example .env
    echo "✅ .env 파일이 생성되었습니다. 설정을 수정해주세요."
else
    echo "✅ .env 파일이 이미 존재합니다."
fi

# Python 가상환경 확인
if [ ! -d ".venv" ]; then
    echo "🐍 Python 가상환경 생성 중..."
    python3 -m venv .venv
    echo "✅ 가상환경이 생성되었습니다."
fi

# 가상환경 활성화
echo "🔧 가상환경 활성화 중..."
source .venv/bin/activate

# 의존성 설치
echo "📦 의존성 설치 중..."
pip install --upgrade pip
pip install -e ".[api]"

# 웹UI 의존성 설치 (bun이 설치된 경우)
if command -v bun &> /dev/null; then
    echo "🌐 웹UI 의존성 설치 중..."
    cd lightrag_webui
    bun install
    cd ..
else
    echo "⚠️ bun이 설치되지 않았습니다. 웹UI 개발을 위해서는 bun 설치가 필요합니다."
fi

# 서버 시작
echo "🎯 LightRAG 서버 시작..."
echo "서버 URL: http://localhost:9621"
echo "중지하려면 Ctrl+C를 누르세요."

lightrag-server