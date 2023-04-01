# bot-environments

## Steps to create environment

1. Export access keys and auth needed to authenticate your AWS with TF

2. Terraform init

3. Terraform apply

4. Once done, SSH into your instance using command:
    - `ssh -i ~/.ssh/id_rsa.pub ec2-user@<INSTANCE_PUBLIC_IP>`

5. To SSH into the instance from the machine you need to add this block into the `sg.tf` file.

```
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your.public.ip.address/32"]
  }
}
```

## What is this environment for?

- Any bots we create as @Deengineers.



## Current bots:

- [No Hello Bot](https://github.com/Deengineers/no-hello-bot)
- [Job Bot](https://github.com/Deengineers/discord-job-bot)
    - Set SHORT-TOK >> `export SHORT-TOK=PUT-SHORT-TOKEN-HERE`
    - Set TOKEN >> `export TOKEN=PUT-DISCORD-TOKEN-HERE`
    - Set ChannelID > `export JOBBOARDCHANNEL=<CHANNELID-HERE>`