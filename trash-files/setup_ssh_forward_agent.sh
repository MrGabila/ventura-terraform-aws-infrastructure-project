#!/bin/bash
exec ssh-agent bash
eval 'ssh-agent -s'
ssh-agent bash
ssh-add -L
ssh-add -k [/path-to-keyfile]
ssh-add -L
ssh -A -i "private key" USER_NAME@publicIP
