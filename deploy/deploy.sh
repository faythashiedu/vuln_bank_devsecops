#!/bin/bash
# deploy/deploy.sh

# Exit on error
set -e

echo "Starting deployment..."

# Variables
EC2_HOST="${EC2_HOST}"
SSH_KEY="${SSH_PRIVATE_KEY}"
APP_NAME="vulnerable-bank"

# Save SSH key
echo "$SSH_KEY" > app_sec.pem
chmod 600 app_sec.pem

# Build Docker image
echo "Building Docker image..."
docker build -t $APP_NAME .

# Save image to tar
echo "Saving Docker image..."
docker save $APP_NAME > app.tar

# Copy files to EC2
echo "Copying files to EC2..."
scp -i app_sec.pem \
    -o StrictHostKeyChecking=no \
    app.tar \
    ec2-user@${EC2_HOST}:~/

# Deploy on EC2
echo "Deploying on EC2..."
ssh -i app_sec.pem \
    -o StrictHostKeyChecking=no \
    ec2-user@${EC2_HOST} \
    "docker load < app.tar && \
     docker stop $APP_NAME || true && \
     docker rm $APP_NAME || true && \
     docker run -d \
       --name $APP_NAME \
       -p 80:5000 \
       --restart unless-stopped \
       $APP_NAME"

# Cleanup
rm app_sec.pem app.tar

echo "Deployment completed successfully!"
