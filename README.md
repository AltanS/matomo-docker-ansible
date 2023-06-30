# matomo-docker-ansible
Self-hosted matomo stack utlizing docker



## Features
- Automatic SSL via certbot + letsencrypt
- Docker
- Matomo
- Matomo sidecar container for archiving and other cronjobs
- Zero-downtime matomo updates

## Architecture
- NGINX Firewall and Proxy server
- Dockerized NGINX, Matomo, Matomo Sidecar for archiving & MariaDB

## Installation

### Requirements
- pipenv
- github profile that exposes your public key to connect to the server
- Copy `.env.example` to `.env` and fill out the necessary variables

### Server provisioning
- set the correct hostname in `group_vars/production/main.yml`
- set a host IP in `hosts`

- run `pipenv shell` from ansible folder
- run `pipenv install`
- install ansible requirements

- `ansible-galaxy install -r requirements.yml`

- provision the server `ansible-playbook provision.yml -e "target_host=production"`

### Deployment
- You can adjust the passwords in db.env or use ansible vaults

`ansible-playbook deploy.yml -e "target_host=production"`

- [official docker compose reference file](https://github.com/matomo-org/docker/blob/master/.examples/nginx/docker-compose.yml)

### Matomo setup

- navigate to the matomo_hostname url
- when configuring the database use `mariadb` as the host machine, and the root credentials from `db.env` for the rest


## random notes
- make sure you customize your matomo logo instance if the instance will be publicly accessible