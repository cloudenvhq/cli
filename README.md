# CloudEnv CLI

Welcome, here's how easy it is to get started with CloudEnv...

```console
$ brew install cloudenvhq/cli/cloudenv
$ cloudenv login
$ cd /var/apps/sampleapp
$ cloudenv init                         # this creates your secret 64-bit key
$ cloudenv merge default .env           # this encrypts your existing env vars into CloudEnv
$ cloudenv merge development .env.dev   # this encrypts your development-specific env vars into CloudEnv
$ cloudenv merge production .env.prod   # this encrypts your production-specific env vars into CloudEnv
```

## Node CloudEnv

```console
$ npm install cloudenv --save
```

```ruby
require("envkey")

process.env.AWS_SECRET_ACCESS_KEY
```

## Ruby CloudEnv

```console
$ gem install cloudenv
```

```ruby
gem "cloudenv"

ENV.fetch("AWS_SECRET_ACCESS_KEY")
```

## Python CloudEnv

```console
$ pip install cloudenv --save
```

```python
import cloudenv
my_var = cloudenv.get("AWS_SECRET_ACCESS_KEY")
```
