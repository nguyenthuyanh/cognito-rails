# 🚀 CognitoRails with AWS Cognito Integration (Dockerized)

This is a **Ruby on Rails** application integrated with **AWS Cognito** for authentication, fully containerized with **Docker** for easy setup and deployment.

## 🔧 Features

- 🔐 AWS Cognito authentication (sign up, login, token validation)
- 🐳 Dockerized development and deployment environment
- ⚙️ API-ready backend
- 🔄 JWT-based session handling
- 🧪 RSpec test suite

---

## 📦 Tech Stack

- **Ruby on Rails** (v7.1.4)
- **PostgreSQL** (via Docker service)
- **AWS Cognito** (SDK: `aws-sdk-cognitoidentityprovider`)
- **Docker & Docker Compose**
- **dotenv** for environment variable management

---

## 🐳 Docker Setup

### 1. Clone the repository

```bash
git clone https://github.com/nguyenthuyanh/cognito-rails
cd cognito-rails
```

### 2. Create environment files

Create a `.env` file in the root directory with AWS and app settings:

```env
RAILS_ENV=development
AWS_REGION=us-east-1
AWS_COGNITO_REGION=xx
AWS_ACCESS_KEY=xx
AWS_COGNITO_DOMAIN=xx
AWS_COGNITO_APP_CLIENT_ID=xx
AWS_COGNITO_REDIRECT_URI=xx
AWS_COGNITO_APP_CLIENT_SECRET=xx
```

### 3. Build and run the containers

```bash
docker-compose up --build
```

The app will be accessible at [http://localhost](http://localhost)

### 4. Run database migrations

In another terminal:

```bash
docker-compose exec app rails db:create db:migrate
```

---

## 🧪 Running Tests

```bash
docker-compose exec app bundle exec rspec
```

---

## 🔐 Authentication Flow

1. Users authenticate through Cognito.
2. The app sends credentials to Cognito using the AWS SDK.
3. Tokens (ID, Access, Refresh) are returned and stored on the client.
4. Backend verifies token signatures using Cognito’s public JWKs.
5. Protected endpoints require valid JWTs.

---

## 📝 License

MIT License. See [LICENSE](LICENSE) for more info.

