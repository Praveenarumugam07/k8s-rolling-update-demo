#!/bin/bash

# Variables
PROJECT_ID="your-gcp-project-id"
REGION="us-central1"
REPO="rolling-demo-repo"
IMAGE_V1="us-central1-docker.pkg.dev/$PROJECT_ID/$REPO/rolling-demo:v1"
IMAGE_V2="us-central1-docker.pkg.dev/$PROJECT_ID/$REPO/rolling-demo:v2"

# Authenticate Artifact Registry
gcloud auth configure-docker $REGION-docker.pkg.dev

# Build & push v1
echo "Building and pushing v1..."
cd v1
docker build -t $IMAGE_V1 .
docker push $IMAGE_V1
cd ..

# Build & push v2
echo "Building and pushing v2..."
cd v2
docker build -t $IMAGE_V2 .
docker push $IMAGE_V2
cd ..

# Deploy v1
echo "Deploying v1..."
sed "s|IMAGE_PLACEHOLDER|$IMAGE_V1|g" deployment.yaml | kubectl apply -f -

# Wait for pods
echo "Waiting for deployment rollout..."
kubectl rollout status deployment/rolling-demo

# Rolling update to v2
echo "Updating to v2..."
kubectl set image deployment/rolling-demo rolling-demo=$IMAGE_V2

# Observe rollout
echo "Observing rollout..."
kubectl rollout status deployment/rolling-demo

echo "Rolling update completed."
