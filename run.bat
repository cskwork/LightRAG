@echo off
REM LightRAG 서버 시작 스크립트 (Windows)
setlocal enabledelayedexpansion

echo 🚀 LightRAG 서버 시작 중...

REM 환경 설정 파일 복사
if not exist ".env" (
    echo 📋 환경 설정 파일 생성 중...
    copy env.example .env >nul
    echo ✅ .env 파일이 생성되었습니다. 설정을 수정해주세요.
) else (
    echo ✅ .env 파일이 이미 존재합니다.
)

REM Python 가상환경 확인
if not exist ".venv" (
    echo 🐍 Python 가상환경 생성 중...
    python -m venv .venv
    if errorlevel 1 (
        echo ❌ 가상환경 생성에 실패했습니다. Python이 설치되어 있는지 확인해주세요.
        pause
        exit /b 1
    )
    echo ✅ 가상환경이 생성되었습니다.
)

REM 가상환경 활성화
echo 🔧 가상환경 활성화 중...
call .venv\Scripts\activate.bat

REM 의존성 설치
echo 📦 의존성 설치 중...
python -m pip install --upgrade pip
pip install -e ".[api]"

REM 웹UI 의존성 설치 (bun이 설치된 경우)
where bun >nul 2>&1
if %errorlevel% == 0 (
    echo 🌐 웹UI 의존성 설치 중...
    cd lightrag_webui
    bun install
    cd ..
) else (
    echo ⚠️ bun이 설치되지 않았습니다. 웹UI 개발을 위해서는 bun 설치가 필요합니다.
)

REM 서버 시작
echo 🎯 LightRAG 서버 시작...
echo 서버 URL: http://localhost:9621
echo 중지하려면 Ctrl+C를 누르세요.

lightrag-server

pause