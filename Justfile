set shell := ["sh", "-c"]

# Default recipe to display help
default:
    @just --list

# Install dependencies
setup:
    mix deps.get

# Update dependencies
update-deps:
    mix deps.update --all

# Clean build artifacts
clean:
    mix clean
    rm -rf _build deps

# Start the Phoenix server
server:
    mix phx.server

# Start the Phoenix server with IEx
iex:
    iex -S mix phx.server

# Run the application
serve: generate migrate
    mix phx.server

# Format code
format:
    mix format

# Check code formatting
format-check:
    mix format --check-formatted

# === Testing & Quality ===

# Run tests
test:
    mix test

# Run tests with coverage
test-coverage:
    mix test --cover

# Run Credo for code analysis
lint:
    mix credo

# Run Credo with strict mode
lint-strict:
    mix credo --strict

# === Database (Postgres) ===

# Create database
db-create:
    mix ecto.create

# Drop database
db-drop:
    mix ecto.drop

# Run migrations
migrate:
    mix ecto.migrate

# Rollback last migration
rollback:
    mix ecto.rollback

# Rollback all migrations
rollback-all:
    mix ecto.rollback --all

# Reset database (drop, create, migrate)
db-reset:
    mix ecto.reset

# Check migration status
db-status:
    mix ecto.migrations

# Generate a new migration
migration name:
    mix ecto.gen.migration {{name}}

# === Swagger Documentation ===

# Generate Swagger documentation
generate:
    mix phx.swagger.generate

# Build Docker image for the application
docker-build:
    podman build -t messaging:latest .

# Compile the project
compile:
    mix compile

# Build production release
release:
    MIX_ENV=prod mix release

# Build and run production release
release-run: release
    _build/prod/rel/messaging/bin/messaging start

# Generate a secret key base for production
gen-secret:
    mix phx.gen.secret

# Show routes
routes:
    mix phx.routes

# Open IEx console
console:
    iex -S mix

# Run all quality checks (format, lint, test)
check: format-check lint test

# Full setup (deps, create db, migrate, generate swagger)
init: setup db-create migrate generate

