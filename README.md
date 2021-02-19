## Welcome to CloudEnv

E2E Encrypted Secrets Management

Are you tired of sharing environmental variables over email and Slack?

Are solutions like Vault too complicated and 1Password too clunky?

Sync your secrets with [CloudEnv](httsp://cloudenv.com), the easiest and most secure secret management platform there is.

### CloudEnv CLI

Welcome, here's how easy it is to get started with CloudEnv...

```console
$ bash -c "$(curl -fsSL https://raw.githubusercontent.com/cloudenvhq/install/main/install.sh)"
$ cloudenv login
$ cd /var/apps/sampleapp
$ cloudenv init                         # this creates a secret 256-bit key for the project
$ cloudenv push default .env            # this encrypts your existing env vars into CloudEnv
$ cloudenv push development .env.dev    # this encrypts your development-specific env vars into CloudEnv
$ cloudenv push staging .env.staging    # this encrypts your staging-specific env vars into CloudEnv
$ cloudenv push production .env.prod    # this encrypts your production-specific env vars into CloudEnv
$ cloudenv edit production              # edit your env vars locally, as soon as you save,
$                                       #   they are encrypted and uploaded to CloudEnv
$                                       #   and instantly distributed to other team members and environments
```

### CloudEnv Universal Integration

```console
$ eval $(cloudenv source) && path/to/start/command
```

[Read More](https://docs.cloudenv.com/pages/installation/universal.html) about how to use CloudEnv with anything.

### CloudEnv Node Integration

```console
$ npm install cloudenv-hq --save
```

```javascript
require("cloudenv-hq")

process.env.AWS_SECRET_ACCESS_KEY
```

[Read More](https://docs.cloudenv.com/pages/installation/node.html) about how to use CloudEnv with Node.

### CloudEnv Ruby Integration

```console
$ gem install cloudenv-hq
```

```ruby
gem "cloudenv-hq"
require "cloudenv-hq"

ENV.fetch("AWS_SECRET_ACCESS_KEY")
```

[Read More](https://docs.cloudenv.com/pages/installation/ruby.html) about how to use CloudEnv with Ruby.

### CloudEnv Python Integration

```console
$ pip install cloudenv
```

```python
import os
import cloudenv
cloudenv.load_cloudenv()

os.getenv("AWS_SECRET_ACCESS_KEY")
```

[Read More](https://docs.cloudenv.com/pages/installation/python.html) about how to use CloudEnv with Python.

### Using CloudEnv to Manage Your Console Secrets

You can use CloudEnv to store and manage your local environmental variables, not just your application variables. All you have to do is run `cloudenv init` inside your home directory and add `cloudenv show` to the source step in your shell profile.

[Read More](https://docs.cloudenv.com/pages/tutorials/console.html) about how to use CloudEnv with your console.

```console
$ cd ~
$ cloudenv init
```

Then you can add this to your `.bash_profile` or `.zshrc` file:

```console
eval $(cloudenv source)
```
