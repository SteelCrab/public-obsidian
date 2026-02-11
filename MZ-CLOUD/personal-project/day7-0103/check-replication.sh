#!/bin/bash
echo ">>> Checking MySQL Slave Verification..."
echo "Pod: mysql-0"
kubectl exec -it mysql-0 -n gition -- mysql -u root -p<ROOT_PASSWORD> -e "SHOW SLAVE STATUS\G" | grep "Slave_.*_Running"

echo ""
echo "Pod: mysql-1"
kubectl exec -it mysql-1 -n gition -- mysql -u root -p<ROOT_PASSWORD> -e "SHOW SLAVE STATUS\G" | grep "Slave_.*_Running"
