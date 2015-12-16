# Togelack

Slack Summary Service (like togetter).

## env
### requirement
- SLACK_TOKEN
    - ex. xoxp-1234567-12345-...
- SLACK_CLIENT_ID
    - App client ID (ex. 1234567)
- SLACK_CLIENT_SECRET
    - App client secret (ex. abcdef12345)
- SLACK_TEAM_ID
    - ex. T1234567
- SLACK_TEAM_NAME
    - ex. toripota
- MONGO_URL
    - database url(ex. localhost:27017)

### optional
- SLACK_CHANNEL
    - notify slack channel (ex. general)
- REDIS_URL
    - use redis cache (ex. redis://localhost)

## LICENSE
MIT

