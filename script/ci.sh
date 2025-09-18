#!/bin/bash
set -e

APP_NAME="teamavail"
IMAGE_TAG="latest"

echo "Starting pipeline"

npm ci

if npm run | grep -q "lint"; then
  echo "Running lint"
  npm run lint
fi

if npm run | grep -q "format"; then
  echo "Running formatter"
  npm run format
fi

echo "Running tests"
npm test || echo "Tests failed, continuing"

echo "Building docker image"
docker build -t ${APP_NAME}:${IMAGE_TAG} .

echo "Deploying application"
docker-compose down --remove-orphans || true
docker-compose up -d

echo "Pipeline finished"
