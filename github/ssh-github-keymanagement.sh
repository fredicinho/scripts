#!/bin/bash
GITHUB_API_TOKEN='Foo'
SSH_KEY_NAME='Baar'
EMAIL='helloworld@example.com'

# Create SSH Key
sudo ssh-keygen -b 2048 -C "$EMAIL" -t rsa -f /root/.ssh/id_rsa -q -N ""
if [ ! -n "$(grep "^github.com " ~/.ssh/known_hosts)" ]; then
  ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null;
fi;
pub=$(cat ~/.ssh/id_rsa.pub)

# Add new SSH Key to your Github Account
keys=$(curl -v -H "Authorization: token $GITHUB_API_TOKEN" https://api.github.com/user/keys > sshkeys.json)

jq -c '.[]' sshkeys.json | while read i; do
  title=$(echo $i | jq -c '.title' | sed 's/"//g')
  if [ "$title" = "$SSH_KEY_NAME" ]; then
    SSH_KEY_ID=$(echo $i | jq -c '.id')
    curl -v -H "Authorization: token $GITHUB_API_TOKEN" -X DELETE "https://api.github.com/user/keys/$SSH_KEY_ID"
    echo "SSH Key with title Chinapolis deleted"
    break
  fi
done

curl -v -H "Authorization: token $GITHUB_API_TOKEN" -X POST -d "{\"title\":\"$SSH_KEY_NAME\",\"key\":\"$pub\"}" https://api.github.com/user/keys
rm sshkeys.json
