# Matomo Docker Ansible
> An Ansible playbook for deploying a self-hosted Matomo stack using Docker, complete with an NGINX firewall, automatic SSL, MariaDB, and a Matomo sidecar for archiving.

## Features
- Automatic SSL via certbot + letsencrypt
- Docker & Docker Compose
- Matomo
-   Matomo sidecar container for archiving and other cronjobs
- Zero-downtime matomo updates

## Architecture
- NGINX Firewall and Proxy server that has automatic SSL renewals via CertBot
- Dockerized NGINX, Matomo, Matomo Sidecar for archiving & MariaDB

## 1. Installation
I've tested this playbook on a Ubuntu 22.04 VPS. It should work on Debian, but I haven't tried.

### Prerequisites
- A GitHub account that exposes your public SSH key for server connection or add a local public key file by adjusting `group_vars/all/users.yml`
- pipenv installed. [Installation guide](https://pipenv.pypa.io/en/latest/installation/)

### Setup
- Clone the repository and navigate to the Ansible folder.
- Copy the `.env.example` file to `.env` and fill in the necessary variables.
  - This will define your public SSH keys via Github.
- Copy the `vault_pass.txt.example` to `vault_pass.txt`
- Set your host IP in `hosts/production`.

## 2. Server provisioning
The server provisioning playbook will run through the `roles` and setup users, install nginx, docker, certbot, cronjobs for docker cleanup, a systemd entry to restart docker compose on after the machine reboots. 

__Setup the python environment via `pipenv`__

- run `pipenv shell` from ansible folder
- run `pipenv install`

__Install ansible requirements__

- `ansible-galaxy install -r requirements.yml`

__Provision the server__
`ansible-playbook provision.yml -e "target_host=production"`

- This can take a while, but should then finish without errors.

## 3. Deployment
The deployment playbook (deploy.yml) will setup and start docker compose for this stack.

__Setting up secrets__
- You can adjust the passwords in `templates/db.env.j2` directly or make use of encrypted passwords via ansible vaults
- Make sure you've created a new `vault_pass` file and set a secure password inside it
- Then run `ansible vault encrypt ./group_vars/production/secrets.yml`. When running `encrypt` ansible will always ask for the vault_pass you've defined in the previous step. For other commands it will use the `vault_pass.txt` file, you can change this in the `ansible.cfg`.
- If you want to edit it run `ansible vault decrypt FILENAME` or `ansible vault edit FILENAME`, it will read the password now from the

### Running the deployment playbook
This playbook sets up the docker compose stack in `/opt/matomo-stack`

`ansible-playbook deploy.yml -e "target_host=production"`

This will: 
1. Create a `docker-compose.yml` file on the remote machine to run the stack
  - This is where nginx, mariadb, matomo (running twice in parallel) and a matomo container for archiving via cronjobs
2. Copy the plugins folder
3. Create and mount a folder for nginx logs
4. Start the stack
  - Run docker compose if it's not running
  - Or restart the matomo_containers in sequence so that the plugins are present

- [official docker compose reference file](https://github.com/matomo-org/docker/blob/master/.examples/nginx/docker-compose.yml)

## Matomo setup

- Navigate to the `matomo_hostname` url (set in `.env`)
- The credentials should be populated from the `group_vars/production/secrets.yml` file

### Updating Matomo
- Updating via the admin UI works.
- This is dangerous and can cause the app to break, only do this when you know how to resolve issues that can arise.

## Staging environments to try out updates
This should be easily doable by adding another `hosts` entry and creating variables for `group_vars/staging`
- [ ] TODO
- As the matomo folder (var/www/html) is mounted in a volume that is used across containers (matomo, nginx, matomo-cron), updating only the image won't be enough. the volume would have to be deleted and re-created.
- The database would also have to be copied as matomo updates oftentimes change the DB permanently


## Customize the Matomo Admin UI
- If your login page is publicly accessible, make sure to change the layout of the admin URL ASAP. I have had numerous instances now that were flagged by Google as phishing websites, which causes a big headache (can be resolved in the Search Console). 
- So make sure to customize the logo and favicon in the Matomo admin UI (System -> General Settings -> Branding settings)
- There is a plugin that can be activated to change color of the header color as well (`matomo-plugins/CustomHeaderColor`)

## Plugins
- Add your matomo plugins in the `matomo-plugins` folder. I have added an example plugin in there
- Once you've added these, re-run the deploy playbook. This will re-create the docker-compose file, which will mount every plugin into the containers running matomo and restart the stack without downtime

## Nginx
- There are 2 instances of nginx running

### NGINX on the Docker host
- Config file is copied from `roles/nginx-setup/templates/server.conf.j2`
- When changes are made, re-run the provision playbook

### NGINX in the docker stack

- Config file is copied from `templates/matomo.conf`
- When changes to this file are made:
1. Re-run the deploy playbook
2. restart nginx in the container (this will cause a little downtime)

``` bash
# on the docker host
su ansibleadmin
cd /opt/matomo-stack

docker ps #get the container id of matomo-stack_nginx
docker exec -it CONTAINER_ID sh
# in the container
nginx -s reload
exit
```


## MariaDB
- [ ] TODO: setup a backup playbook
- Currently there is no playbook or task to get a backup of mariadb
- I'd recommend manually dumping the database, a folder is mounted in the mariadb container so the dumps would be available on the host machine
