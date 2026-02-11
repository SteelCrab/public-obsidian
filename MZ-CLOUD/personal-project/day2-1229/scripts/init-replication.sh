#!/bin/bash
# =============================================================================
# MySQL Master-Slave Replication 초기화 스크립트
# =============================================================================
# 실행 위치: k8s-m (Master 노드)
# 사용법:
#   1. cp .env.example .env
#   2. .env 파일 수정
#   3. ./init-replication.sh
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# .env 파일 로드
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [ -f "$ENV_FILE" ]; then
    echo "📁 .env 파일 로드: $ENV_FILE"
    source "$ENV_FILE"
else
    echo "❌ .env 파일이 없습니다. .env.example을 복사하세요"
    echo "   cp ${SCRIPT_DIR}/.env.example ${SCRIPT_DIR}/.env"
    echo ""
    echo "또는 환경 변수를 직접 설정하세요:"
    echo "   export MYSQL_ROOT_PASSWORD=<password>"
    echo "   export MYSQL_REPL_PASSWORD=<password>"
    exit 1
fi

# -----------------------------------------------------------------------------
# 환경 변수 검증
# -----------------------------------------------------------------------------
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD가 설정되지 않았습니다}"
: "${MYSQL_REPL_PASSWORD:?MYSQL_REPL_PASSWORD가 설정되지 않았습니다}"
: "${MYSQL_PRIMARY_HOST:=172.100.100.11}"
: "${MYSQL_REPL_USER:=repl_pista}"
: "${NAMESPACE:=gition}"

echo ""
echo "============================================"
echo "🐬 MySQL Master-Slave Replication 초기화"
echo "============================================"
echo "Master Host: ${MYSQL_PRIMARY_HOST}"
echo "Repl User:   ${MYSQL_REPL_USER}"
echo "Namespace:   ${NAMESPACE}"
echo "============================================"

# -----------------------------------------------------------------------------
# 1. Master 상태 확인
# -----------------------------------------------------------------------------
echo ""
echo "[1/4] Master 상태 확인..."
ssh mysql "docker exec mysql-master mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'SHOW MASTER STATUS\G'" 2>/dev/null | tee /tmp/master_status.txt

# GTID 모드 확인
GTID_MODE=$(ssh mysql "docker exec mysql-master mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'SHOW VARIABLES LIKE \"gtid_mode\"'" 2>/dev/null | grep -i on || true)
if [ -z "$GTID_MODE" ]; then
    echo "⚠️ 경고: GTID 모드가 활성화되지 않았습니다"
    echo "   my.cnf에서 gtid_mode = ON 설정을 확인하세요"
fi

# -----------------------------------------------------------------------------
# 2. Slave Pod 대기
# -----------------------------------------------------------------------------
echo ""
echo "[2/4] Slave Pod 준비 대기..."
kubectl wait --for=condition=ready pod/mysql-0 -n ${NAMESPACE} --timeout=120s 2>/dev/null || echo "  mysql-0: 대기 중 또는 없음"
kubectl wait --for=condition=ready pod/mysql-1 -n ${NAMESPACE} --timeout=120s 2>/dev/null || echo "  mysql-1: 대기 중 또는 없음"

# -----------------------------------------------------------------------------
# 3. Slave 복제 설정
# -----------------------------------------------------------------------------
echo ""
echo "[3/4] Slave 복제 설정..."

for POD in mysql-0 mysql-1; do
    # Pod 존재 여부 확인
    if ! kubectl get pod ${POD} -n ${NAMESPACE} &>/dev/null; then
        echo "  ⚠️ ${POD}: Pod 없음, 건너뜀"
        continue
    fi
    
    echo ""
    echo "--- ${POD} 설정 중 ---"
    
    # 기존 복제 중지 (있을 경우)
    kubectl exec -n ${NAMESPACE} ${POD} -- mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "STOP SLAVE;" 2>/dev/null || true
    kubectl exec -n ${NAMESPACE} ${POD} -- mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "RESET SLAVE ALL;" 2>/dev/null || true
    
    # Master 연결 설정 (GTID 기반)
    kubectl exec -n ${NAMESPACE} ${POD} -- mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "
        CHANGE MASTER TO
            MASTER_HOST='${MYSQL_PRIMARY_HOST}',
            MASTER_USER='${MYSQL_REPL_USER}',
            MASTER_PASSWORD='${MYSQL_REPL_PASSWORD}',
            MASTER_AUTO_POSITION=1;
    " 2>/dev/null
    
    # 복제 시작
    kubectl exec -n ${NAMESPACE} ${POD} -- mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "START SLAVE;" 2>/dev/null
    
    echo "✅ ${POD} 복제 설정 완료"
done

# -----------------------------------------------------------------------------
# 4. 복제 상태 확인
# -----------------------------------------------------------------------------
echo ""
echo "[4/4] 복제 상태 확인..."
echo ""

for POD in mysql-0 mysql-1; do
    if ! kubectl get pod ${POD} -n ${NAMESPACE} &>/dev/null; then
        continue
    fi
    
    echo "=== ${POD} Slave Status ==="
    kubectl exec -n ${NAMESPACE} ${POD} -- mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW SLAVE STATUS\G" 2>/dev/null | grep -E "(Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master|Last_Error)" || echo "  상태 조회 실패"
    echo ""
done

echo "============================================"
echo "✅ MySQL Replication 초기화 완료!"
echo "============================================"
echo ""
echo "📋 확인 명령어:"
echo "  kubectl exec -n ${NAMESPACE} mysql-0 -- mysql -uroot -p<PASSWORD> -e 'SHOW SLAVE STATUS\\G'"
echo "  kubectl exec -n ${NAMESPACE} mysql-1 -- mysql -uroot -p<PASSWORD> -e 'SHOW SLAVE STATUS\\G'"
