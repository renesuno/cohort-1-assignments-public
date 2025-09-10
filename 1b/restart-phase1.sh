#!/bin/bash
echo "🚀 Phase 1 재시작 중..."

# Docker 컨테이너 시작
docker compose up -d

# 잠시 대기 후 상태 확인
sleep 10
docker compose ps

echo "📡 Ngrok 시작 안내:"
echo "새 터미널에서 실행: ngrok http 8080 --domain=unreligious-oakley-unwhimperingly.ngrok-free.app"

echo "✅ Phase 1 재시작 완료!"
