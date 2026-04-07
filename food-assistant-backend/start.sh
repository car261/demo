#!/bin/bash

# Start the services using Docker Compose
docker-compose up --build -d

echo "Services started:"
echo "- MongoDB: localhost:27017"
echo "- Redis: localhost:6379"
echo "- Flask App: localhost:5000"
echo ""
echo "To stop services: docker-compose down"
echo "To view logs: docker-compose logs -f"