sh -c "echo deb http://get.docker.io/ubuntu docker main\
> /etc/apt/sources.list.d/docker.list"
apt-get -q -y update
apt-get -q -y --force-yes install lxc-docker git python-pip
pip install -U fig
