#!/bin/bash
# scripts/health_check.sh

MAX_RETRIES=10
RETRY_INTERVAL=2

echo "Starting Flask application..."
nohup python app.py > app.log 2>&1 &
APP_PID=$!

for i in $(seq 1 $MAX_RETRIES); do
    echo "Attempt $i of $MAX_RETRIES to check application health..."
    if curl -s http://localhost:5000/health > /dev/null; then
        echo "Application is running!"
        exit 0
    fi
    sleep $RETRY_INTERVAL
done

echo "Application failed to start. Logs:"
cat app.log
exit 1
