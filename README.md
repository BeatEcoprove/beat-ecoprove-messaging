# 🌱 Beat Messaging Service

> Real-time messaging microservice powering sustainable communities through chat, notifications, and group collaboration.

Part of the **Beat EcoProve** ecosystem - where sustainability meets technology.

## ✨ What Does This Do?

Beat Messaging Service is the communication backbone of the Beat platform. It enables users to:

- 💬 **Chat in real-time** with group members about sustainability initiatives
- 👥 **Manage groups** where users collaborate on eco-friendly projects
- 📨 **Share and track borrow requests** for clothing items (because sharing is caring!)
- 🔔 **Receive instant notifications** about invites, messages, and group activities
- 🎯 **Earn sustainability points and XP** through group participation

Think of it as your eco-community's communication hub - where every message, invite, and notification helps build a more sustainable future.

## 🏗️ Architecture at a Glance

This microservice is built on event-driven architecture:

- **Real-time WebSocket channels** for instant messaging
- **Kafka event bus** for inter-service communication
- **PostgreSQL** for users, groups, members, and invites
- **MongoDB** for high-volume message storage
- **Redis** for caching and presence tracking

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have:

- **Elixir** 1.18.0 or higher
- **Erlang/OTP** 28 or higher
- **Docker** and **Docker Compose** (for infrastructure)

> **💡 Tip:** Check your versions with `elixir --version` and `erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell`

### Step 1: Clone and Enter

```bash
git clone <repository-url>
cd messaging
```

### Step 2: Configure Your Environment

Copy the example environment file:

```bash
cp .env.example .env
```

Then edit `.env` with your configuration. Here's a quick reference:

```env
# Microservice URLs
BEAT_MESSASSING_SERVER=http://localhost:4000
BEAT_IDENTITY_SERVER=http://localhost:4001
SECRET_KEY_BASE=generate-a-secret-key-here

# PostgreSQL (user data, groups, invites)
POSTGRES_DB=messaging_dev
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_PORT=5432
POSTGRES_HOST=localhost

# Redis (caching and presence)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_UI_PORT=8001
REDIS_DB=0

# MongoDB (message storage)
MONGO_USERNAME=admin
MONGO_PASSWORD=admin
MONGO_HOST=localhost
MONGO_PORT=27017
MONGO_DB=messaging

# Kafka (event streaming)
KAFKA_HOST=localhost
KAFKA_PORT=9092
```

> **🔐 Security Note:** Generate a strong `SECRET_KEY_BASE` using: `mix phx.gen.secret`

### Step 3: Start Infrastructure

Fire up all the backing services with one command:

```bash
docker-compose up -d
```

This spins up:
- 🐘 PostgreSQL (port 5432)
- 🍃 MongoDB (port 27017) + Mongo Express UI (port 8081)
- 🔴 Redis (port 6379) + Redis UI (port 8001)
- 📬 Kafka (ports 9092 internal, 9094 external)

### Step 4: Install Dependencies

```bash
mix deps.get
```

### Step 5: Setup Database

Run migrations to create your database schema:

```bash
mix ecto.create
mix ecto.migrate
```

### Step 6: Launch! 🎉

```bash
mix serve
```

Or if you prefer the traditional way:

```bash
mix phx.server
```

Your messaging service is now running at **`http://localhost:4000`**

## 📚 Exploring the API

We've got you covered with **interactive Swagger documentation**!

### Generate and View API Docs

```bash
# Generate the latest API documentation
mix phx.swagger.generate

# Start the server (if not already running)
mix phx.server
```

Then visit: **`http://localhost:4000/api/swagger`**

You'll find complete documentation for all endpoints with:
- Request/response schemas
- Authentication requirements
- Interactive "Try it out" functionality
- Example payloads

### Quick API Overview

All endpoints require JWT authentication via `Authorization: Bearer <token>` header.

**Main Resources:**
- `/api/groups` - Create and manage chat groups
- `/api/groups/:id/messages` - Browse message history
- `/api/groups/:id/invites` - Invite users to groups
- `/api/invites/accept` & `/api/invites/decline` - Manage invitations
- `/api/notifications` - View your notifications

**WebSocket Channels:**
- `group:{group_id}` - Real-time group chat (send text & borrow messages)
- `notification:{user_id}` - Personal notification stream

> 💡 **For complete details**, use the Swagger UI - it's much more fun and interactive!

## 🛠️ Development Commands

```bash
# Install dependencies
mix setup

# Generate Swagger docs
mix generate

# Run migrations and start server
mix serve

# Rollback last migration
mix reset

# Run tests
mix test

# Check code quality
mix credo
```

## 📁 Project Structure

```
lib/
├── messaging/              # Core business logic
│   ├── auth/              # JWT authentication & user presence
│   ├── broker/            # Kafka event bus & event handlers
│   ├── persistence/       # Database schemas & repositories
│   └── redis/             # Redis caching layer
├── messaging_app/         # Application services
│   ├── group/             # Group management
│   ├── invite/            # Invitation system
│   ├── members/           # Member & role management
│   ├── messages/          # Message handling
│   └── notifications/     # Notification delivery
└── messaging_web/         # Web layer
    ├── channels/          # WebSocket channels
    ├── controllers/       # REST API controllers
    └── plugs/             # Auth & scope middleware
```

## 🔄 Event-Driven Architecture

This service communicates with other Beat microservices via Kafka events:

**Published Events:**
- Group lifecycle (created, updated, deleted)
- Member actions (kicked, role changed)
- Messages (text, borrow requests)
- Invitations (created, accepted, declined)

**Consumed Events:**
- User creation (from auth service)
- Group notifications
- System events

This keeps services loosely coupled and enables horizontal scaling! 🚀

## 🧪 Testing

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test file
mix test test/messaging_web/controllers/group_controller_test.exs
```

## 🐛 Troubleshooting

### Can't connect to database?
```bash
# Check if containers are running
docker-compose ps

# Restart infrastructure
docker-compose down && docker-compose up -d

# Reset database
mix ecto.drop && mix ecto.create && mix ecto.migrate
```

### Kafka issues?
```bash
# Check Kafka logs
docker-compose logs kafka-b

# Verify Kafka is ready
docker exec -it kafka-b kafka-topics.sh --list --bootstrap-server localhost:9092
```

### WebSocket won't connect?
1. ✅ Verify your JWT token is valid
2. ✅ Check user has permission to access the channel
3. ✅ Look at server logs for authentication errors

## 🚢 Production Deployment

### Build a Release

```bash
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix phx.swagger.generate
MIX_ENV=prod mix release
```

### Essential Environment Variables

Make sure these are set in production:

```bash
SECRET_KEY_BASE=your-production-secret
DATABASE_URL=postgresql://user:pass@host:5432/db
REDIS_URL=redis://host:6379
MONGO_URL=mongodb://user:pass@host:27017/db
KAFKA_BROKERS=kafka1:9092,kafka2:9092
```

### Run the Release

```bash
_build/prod/rel/messaging/bin/messaging start
```

## 📊 Monitoring

Access Phoenix LiveDashboard in development:

**`http://localhost:4000/dashboard`**

Monitor:
- Request throughput
- WebSocket connections
- Memory and process usage
- Database query performance

## 🤝 Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/awesome-feature`)
3. Write tests for your changes
4. Run `mix credo --strict` to ensure code quality
5. Commit your changes (`git commit -m 'Add awesome feature'`)
6. Push to the branch (`git push origin feature/awesome-feature`)
7. Open a Pull Request

## 📄 License

Copyright (c) 2025 Beat EcoProve

## 📬 Contact

**Beat EcoProve** - beatecoprove@gmail.com

---

<div align="center">
Built with 💚 for a sustainable future
</div>
