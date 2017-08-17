# docker-armhf-snort
Dockerfile for amd64 on Ubuntu14.04 / snort

# Build ths container
sudo docker build -t="{name}/{containername}:{version}" .

Example;
sudo docker build -t="myproject/snort:1.0" .

# Instructions

Pulledpork;
sudo /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -l 

Snort;
sudo /usr/local/bin/snort -u snort -g snort -c /etc/snort/snort.conf -i eth0 -D

Barnyard2;
sudo barnyard2 -c /etc/snort/barnyard2.conf -d /var/log/snort -f snort.u2 -w /var/log/snort/barnyard2.waldo -g snort -u snort -D
