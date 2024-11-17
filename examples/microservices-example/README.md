# Microservices Example

This example demonstrates a complex microservices architecture with multiple layers and dependencies. It's designed to showcase how the Docker Graceful Shutdown utility handles complex container dependencies and networks.

## Architecture

The architecture consists of three main layers:

1. Frontend Layer
   - nginx-proxy: Reverse proxy for the entire application
   - web-app: Node.js web application

2. API Layer
   - api-gateway: API Gateway service
   - auth-service: Authentication service
   - user-service: User management service
   - product-service: Product management service

3. Data Layer
   - mongodb: Document database for user and auth services
   - postgres: Relational database for product service
   - redis: Cache for auth service

## Networks

- frontend: External-facing network for frontend services
- internal: Internal network for service-to-service communication

## Running the Example

1. Start the stack:
   ```powershell
   docker-compose up -d
   ```

2. Test the graceful shutdown:
   ```powershell
   .\gracefully_shutdown_all_docker_containers.ps1
   ```

The script should shut down containers in the correct order:
1. Frontend services (nginx-proxy, web-app)
2. API services (api-gateway, auth-service, user-service, product-service)
3. Data services (redis, mongodb, postgres)

## Expected Behavior

The script will:
1. Detect all container dependencies from both networks and docker-compose
2. Create a dependency graph
3. Determine the correct shutdown order
4. Gracefully stop containers in reverse dependency order
