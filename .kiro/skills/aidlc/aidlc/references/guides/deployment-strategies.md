# Deployment Strategies Guide

Reference guide for deployment approaches and rollback strategies.

## Deployment Strategies

### Blue-Green Deployment
Two identical environments (blue and green). Deploy to inactive, then switch traffic.

**Pros**: Zero downtime, instant rollback
**Cons**: Requires double resources, database migrations tricky
**Use when**: Need instant rollback, can afford double resources

### Canary Deployment
Deploy to small subset of users first, gradually increase.

**Pros**: Reduced risk, real user feedback
**Cons**: Complex routing, longer deployment time
**Use when**: High-risk changes, large user base

### Rolling Deployment
Update instances one at a time.

**Pros**: No extra resources needed, gradual rollout
**Cons**: Mixed versions running, slower rollback
**Use when**: Resource-constrained, low-risk changes

### Recreate
Stop old version, deploy new version.

**Pros**: Simple, clean state
**Cons**: Downtime during deployment
**Use when**: Downtime acceptable, simple applications

## Rollback Strategies

### Instant Rollback
- Keep previous version ready
- Switch traffic back immediately
- Use with blue-green or canary

### Version Rollback
- Redeploy previous version
- Takes time but reliable
- Use with rolling or recreate

### Database Rollback
- Backward-compatible migrations
- Never delete columns in same release
- Use feature flags for schema changes

## Environments

### Development
- Auto-deploy on every commit
- Latest features, may be unstable
- Used for active development

### Staging
- Auto-deploy on main branch
- Production-like environment
- Used for final testing

### Production
- Manual approval required
- Stable, monitored closely
- Serves real users

## Best Practices

1. Always have a rollback plan
2. Test rollback procedures regularly
3. Use feature flags for risky changes
4. Monitor deployments closely
5. Automate as much as possible
6. Document deployment procedures
7. Keep deployment windows short
