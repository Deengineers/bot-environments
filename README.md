# bot-environments

## Steps to create environment

1. Export access keys and auth needed to authenticate your AWS with TF

2. Terraform init

3. Terraform apply

4. Once done, SSH into your instance using command:
    - `ssh -i ~/.ssh/discord_rsa.pub ec2-user@<INSTANCE_PUBLIC_IP>`


## What is this environment for?

- Any bots we create as @Deengineers.

## Current bots:

- [No Hello Bot](https://github.com/Deengineers/no-hello-bot)
- [Job Bot](https://github.com/Deengineers/discord-job-bot)