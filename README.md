# Togelack

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Slack Summary Service (like togetter).

## How to deploy
- [SlackのTogetter風アプリ「Togelack」をHerokuにデプロイする - Qiita](http://qiita.com/ru_shalm/items/35100b527877cfe09b5e)

## env
### requirement
- RAILS_ENV
    - `"production"`
- MONGOID_ENV
    - `"production"`
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
- SLACK_ICON
    - notify slack icon (ex. :smile: or http://〜)
- REDIS_URL
    - use redis cache (ex. redis://localhost)

## LICENSE
MIT

