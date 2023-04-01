# bot-environments

## What is this environment for?

- Any bots we create as @Deengineers.

## Steps to create environment

1. Export access keys and auth needed to authenticate your AWS with TF
    - export AWS_ACCESS_KEY_ID=
    - export AWS_SECRET_ACCESS_KEY=
    - export AWS_DEFAULT_REGION=us-east-1

2. Terraform init

3. Terraform apply

4. To SSH into the instance from the machine you need to add this block into the `sg.tf` file.

```
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your.public.ip.address/32"]
  }
}
```

5. Once done, SSH into your instance using command:
    - `ssh -i ~/.ssh/id_rsa.pub ec2-user@<INSTANCE_PUBLIC_IP>`

## Current bots:

- [No Hello Bot](https://github.com/Deengineers/no-hello-bot)
- [Job Bot](https://github.com/Deengineers/discord-job-bot)
    - Set SHORT-TOK >> `export SHORT-TOK=PUT-SHORT-TOKEN-HERE`
    - Set TOKEN >> `export TOKEN=PUT-DISCORD-TOKEN-HERE`
    - Set ChannelID > `export JOBBOARDCHANNEL=<CHANNELID-HERE>`

## Running as containers and using vars in container

- Run container >> `docker run -d -e TOKEN=value -e SHORTTOK=value <CONTAINER-NAME>` 
    - Note: Test without `-d` first to see if container is running/responding