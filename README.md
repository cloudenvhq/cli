# CloudEnv CLI

Welcome, here's how easy it is to get started with CloudEnv...

```console
$ cloudenv login
$ cd /var/apps/sampleapp
$ cloudenv init                         # this creates your secret 64-bit key
$ cloudenv merge default .env           # this merges your existing env keys into CloudEnv
$ cloudenv merge development .env.dev   # this merges your development-specific env keys into CloudEnv
$ cloudenv merge production .env.prod   # this merges your production-specific env keys into CloudEnv
```
