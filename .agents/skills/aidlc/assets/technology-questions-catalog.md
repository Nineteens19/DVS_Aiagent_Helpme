# Technology Questions Catalog

Reference catalog of technology decision topics for D3 (Design Decisions). Select relevant topics based on project complexity and requirements.

## Frontend Stack (ask when system has web UI)

**Ask when**: System has user-facing web interface or units.md shows frontend unit (even if current unit is backend).
**Skip when**: Pure backend/API, mobile-only, or CLI-only.

- **Frontend Framework**: React, Vue, Angular, Svelte, etc.
- **Frontend Architecture**: SPA, SSR, SSG, hybrid
- **Build Tool**: Vite, Webpack, Parcel, esbuild, Turbopack
- **UI Component Library**: Material UI, Ant Design, Chakra, Tailwind, custom
- **State Management**: Redux, Context API, Zustand, Jotai, MobX
- **Form Handling**: React Hook Form, Formik, native, other
- **HTTP Client**: Axios, Fetch API, React Query, SWR
- **Routing**: React Router, Next.js routing, Vue Router, other
- **Testing Framework**: Jest, Vitest, Cypress, Playwright

## Mobile Stack (ask when system has mobile app)

**Ask when**: System has mobile app or units.md shows mobile unit (even if current unit is backend).
**Skip when**: Web-only, pure backend/API, or desktop-only.

- **Mobile Framework**: React Native, Flutter, Native (Swift/Kotlin), Ionic/Capacitor
- **Navigation**: React Navigation, Flutter Navigator, Native navigation
- **State Management**: Redux, MobX, Provider, Riverpod, BLoC
- **Local Storage**: AsyncStorage, MMKV, SharedPreferences, Hive, SQLite
- **Networking**: Axios, Fetch, http (Dart), Retrofit, URLSession
- **Push Notifications**: FCM, APNs, OneSignal, custom
- **Native Modules**: When to use, which features need native code
- **Offline Strategy**: Online-first, Offline-first, Hybrid
- **Testing Framework**: Jest + Detox, flutter_test, XCTest, Espresso

## Backend Stack (ask when system has backend services)

**Ask when**: System has backend services, APIs, or business logic.
**Skip when**: Pure static website or frontend-only prototype with mock data.

- **Backend Language & Runtime**: Node.js, Python, Java, Go, .NET, Ruby
- **Backend Framework**: Express, NestJS, FastAPI, Spring Boot, Gin, etc.
- **API Design Pattern**: REST, GraphQL, gRPC, tRPC, hybrid
- **API Documentation**: OpenAPI/Swagger, GraphQL schema, gRPC proto, none
- **Validation Library**: Joi, Zod, class-validator, Pydantic, other
- **Logging Framework**: Winston, Pino, Bunyan, Python logging, Log4j
- **Error Handling Approach**: Middleware-based, try-catch, Result types, other

## Data Layer (ask when system stores data)

**Ask when**: System has data entities or needs persistence.
**Skip when**: Pure UI prototype or stateless proxy/gateway.

- **Database Technology**: PostgreSQL, MySQL, MongoDB, DynamoDB, etc.
- **Database ORM/Client**: Prisma, TypeORM, Sequelize, Mongoose, raw SQL
- **Migration Tool**: Prisma Migrate, TypeORM migrations, Flyway, Liquibase
- **Caching Strategy**: Redis, Memcached, in-memory, CDN, none for MVP
- **Search Technology**: Elasticsearch, Algolia, database full-text, Typesense, none

## Authentication & Security

- **Authentication Method**: JWT, OAuth 2.0, Session-based, API keys, none (public)
- **Authorization Model**: RBAC, ABAC, simple roles, none
- **Password Hashing**: bcrypt, Argon2, scrypt (if applicable)
- **Security Headers**: Helmet.js, custom middleware, framework defaults

## Infrastructure & Deployment

- **Cloud Provider**: AWS, Azure, GCP, self-hosted, hybrid
- **Compute Platform**: Containers (ECS/EKS), Serverless (Lambda), VMs (EC2), PaaS (Heroku)
- **Container Orchestration**: ECS, EKS/Kubernetes, Docker Compose, none
- **CI/CD Tool**: GitHub Actions, GitLab CI, AWS CodePipeline, Jenkins, CircleCI
- **Artifact Registry**: ECR, Docker Hub, GitHub Packages, Artifactory

**Note**: For IaC tool selection, see "Infrastructure as Code" section. For frontend hosting, see "Frontend Hosting" section.

## Observability & Operations

- **Logging Destination**: CloudWatch, ELK Stack, Datadog, Splunk, local files
- **Metrics Collection**: CloudWatch Metrics, Prometheus, Datadog, New Relic, none
- **Distributed Tracing**: AWS X-Ray, Jaeger, Zipkin, Datadog APM, none for MVP
- **Error Tracking**: Sentry, Rollbar, Bugsnag, CloudWatch, none
- **Alerting**: CloudWatch Alarms, PagerDuty, Opsgenie, email, none

## Testing Strategy

- **Unit Test Framework**: Jest, Vitest, Pytest, JUnit, Go testing, Mocha
- **Integration Test Approach**: Supertest, TestContainers, in-memory DB, test environment
- **E2E Test Framework**: Playwright, Cypress, Selenium, Puppeteer, none for MVP
- **API Testing**: Postman, REST Client, Insomnia, automated tests, none
- **Load Testing**: k6, JMeter, Gatling, Locust, none for MVP
- **Correctness & Property-Based Testing** (MANDATORY): How to verify correctness properties

## Configuration & Environment

- **Configuration Management**: Environment variables, config files, AWS Parameter Store, Secrets Manager
- **Secret Management**: AWS Secrets Manager, HashiCorp Vault, environment variables, config files
- **Environment Strategy**: Dev/Staging/Prod separation, feature flags, blue-green

## Code Organization

- **Architecture Pattern**: Layered, Clean Architecture, Hexagonal, Feature-based, MVC
- **Code Style Enforcement**: ESLint, Prettier, Black, Checkstyle, none

## Repository Structure

**When to ask**: Always (for any project with source code)

- **Repository Strategy**: Monorepo (single repo for all services/packages), Multi-repo (separate repo per service), Single repo (one service, one repo)
- **Monorepo Tool** (if monorepo): Nx, Turborepo, Lerna, Rush, Bazel, pnpm workspaces, none
- **Package Manager**: npm, yarn, pnpm, bun (JS/TS); pip, poetry, uv (Python); Maven, Gradle (Java); Go modules (Go)
- **Branch Strategy**: Git Flow, GitHub Flow, Trunk-based development, custom

**See**: `{GUIDES_DIR}/architecture-patterns.md` for detailed repository patterns

## Frontend Hosting (ask when system has web UI)

**Ask when**: System has web interface with frontend framework selected.
**Skip when**: Pure backend/API, mobile-only, or CLI-only.

- **Hosting Platform**: AWS Amplify, Vercel, Netlify, CloudFront + S3, Azure Static Web Apps, Firebase Hosting, self-hosted (Nginx/Apache)
- **CDN**: CloudFront, Cloudflare, Fastly, Vercel Edge, none
- **Domain & SSL**: Route 53, Cloudflare DNS, custom DNS; ACM, Let's Encrypt, provider-managed
- **Deployment Strategy**: Atomic deploys, rolling, blue-green, preview deployments per PR

## Infrastructure as Code (ask when system needs infrastructure)

**Ask when**: System will be deployed to cloud infrastructure with provisioned resources.
**Skip when**: Pure local/desktop app, fully managed PaaS with no custom infra, or prototype with manual setup.

- **IaC Tool**: AWS CDK, Terraform, CloudFormation, Pulumi, SST, Serverless Framework, none (manual)
- **IaC Language** (if CDK/Pulumi): TypeScript, Python, Java, Go, C#
- **State Management** (if Terraform): S3 + DynamoDB, Terraform Cloud, local, GitLab-managed
- **Environment Strategy**: Separate stacks per environment, parameterized single stack, account-per-environment
- **Module/Construct Strategy**: Custom constructs/modules, community constructs, L1/L2/L3 (CDK), monolithic template

## Distributed System Patterns (if microservices/distributed architecture)

**Ask when**: Architecture from D2 is Microservices/Distributed, or multiple services need coordination.
**Skip when**: Monolithic, single service, or simple CRUD.

**See**: `{GUIDES_DIR}/distributed-patterns.md` for detailed pattern explanations

- **Consistency Model**: Strong consistency, Eventual consistency, Causal consistency
- **Distributed Transactions**: Saga (Choreography), Saga (Orchestration), 2PC, Avoid (use idempotency)
- **CQRS**: Yes (separate read/write models), No (unified model)
- **Event Sourcing**: Yes (store events), No (store current state)
- **Locking Strategy**: Optimistic locking, Pessimistic locking, Distributed locks, None
- **Outbox Pattern**: Yes (atomic events), No (direct publishing)
- **Idempotency**: Required (with idempotency keys), Optional, Not needed
- **Circuit Breaker**: Enabled (for external calls), Disabled
- **Retry Strategy**: Exponential backoff with jitter, Fixed delay, No retries

## Non-Functional Requirements Topics

### Performance
- **Performance Targets**: response time, throughput, concurrent users
- **Performance Optimization**: caching, CDN, database indexing, code splitting
- **Load Testing Requirements**: expected load, peak load, testing approach

### Scalability
- **Scalability Approach**: horizontal auto-scaling, vertical scaling, fixed capacity
- **Database Scaling**: read replicas, sharding, connection pooling
- **Rate Limiting**: per-user, per-IP, per-endpoint, none

### Security
- **Security Level**: basic, standard, enterprise, compliance-driven
- **Data Encryption**: at rest, in transit, both, none
- **Input Validation**: strict, standard, basic
- **Dependency Scanning**: automated, manual, none

### Availability & Reliability
- **Availability Target**: 99.9%, 99.5%, best effort
- **Disaster Recovery**: backup strategy, RTO/RPO targets
- **Health Checks**: endpoint-based, process-based, none
- **Circuit Breaker**: enabled, disabled, specific services only

### Monitoring & Alerting
- **Monitoring Depth**: basic logging, logs + metrics, full observability
- **Alert Channels**: email, Slack, PagerDuty, SMS
- **Alert Conditions**: error rate, response time, resource utilization

## Example Question Format

```markdown
### D3-X: [Topic Name]
**Question**: [Specific question about this technology choice]
- 1) [Option 1] ([brief rationale]) **(Recommended)** [if applicable]
- 2) [Option 2] ([brief rationale])
- 3) [Option 3] ([brief rationale])
- 4) Other (please specify): _______

**Answer**: 
```

## Notes

- Architecture Pattern (monolith/microservices/serverless) is decided in D2, not D3
- Select 8-15 questions based on project complexity
- Always include the Correctness & Property-Based Testing question
- Always include Repository Structure question
- Include Infrastructure as Code question for any cloud-deployed system
- Include Frontend Hosting question for any system with web UI
- Adapt questions to the specific project requirements
- Don't ask about technologies that aren't relevant to the project
