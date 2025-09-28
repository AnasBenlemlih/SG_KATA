#!/bin/bash
echo "Building application..."
mvn clean package -DskipTests
echo "Build completed!"
