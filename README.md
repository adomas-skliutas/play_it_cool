# PlayItCool.Umbrella

A game project.
Frontend: Typescript, React, Redux, Apollo, Phoenix
Backend: Elixir, Phoenix, Absinthe, PostgreSQL

## Setup

Prerequisites:

- Elixir (I'm using 1.10.1)
- OTP (I'm using 22)
- docker
- docker-compose

```
  # at root of project
  docker-compose -f docker-compose.dev.yml up -d
  mix setup
```

To populate database for testing

```
  mix apps/play_it_cool/priv/repo/seeds.exs
```

## Running project

```
  # at root of project
  iex -S mix phx.server # of if you don't want iex for debuging: mix phx.server
```

By default project is running on port 4000

## Deployment to Gigalixir

The video guide on home page does a good job on describing how to deploy to [Gigalixir](https://www.gigalixir.com/)

Currently this project can be found [Here](https://unruly-attached-racer.gigalixirapp.com/)
If the link doesn't work ¯\\\_(ツ)\_/¯

## Deployment to DigitalOcean via terraform (deprecated)

> DigitalOcean is quite expensive so I decided to switch to Gigalixir

This project was made to deploy to DigitalOcean with terraform.
To run these commands you need terraform installed locally.

You need to have DigitalOcean ssh fingerprint and private access token in your env variables

```
  export DO_PAT=<your private access token>
  export DO_SSH_FINGERPRINT=<your ssh fingerprint>
  export DOMAIN_NAME=<your domain name>
```

Then cd to terraform dir and execute terraform commands

```
  cd terraform
  terraform init
  terraform apply -var "do_token=${DO_PAT}" -var "pub_key=$HOME/.ssh/id_rsa.pub" -var "pvt_key=$HOME/.ssh/id_rsa" -var "ssh_fingerprint=${DO_SSH_FINGERPRINT} -var domain_name=${DOMAIN_NAME}"
```
