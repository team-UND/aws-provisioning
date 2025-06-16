#!/bin/bash
# user_data.sh for Ubuntu EC2

echo "Updating system and installing necessary packages..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  unzip \
  wget \
  jq

echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker

echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin
rm -rf awscliv2.zip aws/

echo "Installing AWS CodeDeploy Agent..."
sudo apt install -y ruby-full
wget "https://aws-codedeploy-${aws_region}.s3.${aws_region}.amazonaws.com/latest/install" -O /tmp/install
chmod +x /tmp/install
sudo /tmp/install auto
rm /tmp/install
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent

echo "User data script execution completed."