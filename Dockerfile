#sudo docker build -t="mylamp/lamp:v1" .
FROM armv7/armhf-ubuntu:14.04
#FROM ubuntu:14.04
MAINTAINER Opart Moxes
# Install Requirements
RUN apt-get update && apt-get install -y build-essential libpcap-dev libpcre3-dev libdumbnet-dev \
bison flex zlib1g-dev nano wget git curl libmysqlclient-dev mysql-client autoconf libtool \
libcrypt-ssleay-perl liblwp-useragent-determined-perl

# ----RUN Script-----
RUN mkdir /root/snort_src
WORKDIR /root/snort_src/

#install DAQ 2.0.6 and install snort 2.9.9.0
RUN wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz && \
wget https://www.snort.org/downloads/snort/snort-2.9.9.0.tar.gz && \
tar -xvzf daq-2.0.6.tar.gz && \
tar -xvzf snort-2.9.9.0.tar.gz

WORKDIR /root/snort_src/daq-2.0.6

RUN ./configure && make -j3 && \
sudo make install

WORKDIR /root/snort_src/snort-2.9.9.0

RUN ./configure --enable-sourcefire && \
make -j3 && sudo make install

WORKDIR /root/snort_src

RUN ldconfig && \
sudo ln -s /usr/local/bin/snort /usr/sbin/snort && \

#Add user "snort" and groupadd "snort"
groupadd snort && \
useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort && \

# Create the Snort directories:
mkdir /etc/snort && \
mkdir /etc/snort/rules && \
mkdir /etc/snort/rules/iplists && \
mkdir /etc/snort/preproc_rules && \
mkdir /usr/local/lib/snort_dynamicrules && \
mkdir /etc/snort/so_rules && \

# Create some files that stores rules and ip lists
touch /etc/snort/rules/iplists/default.blacklist && \
touch /etc/snort/rules/iplists/default.whitelist && \
touch /etc/snort/rules/local.rules && \

# Create our logging directories:
mkdir /var/log/snort && \
mkdir /var/log/snort/archived_logs && \

# Adjust permissions:
chmod -R 5775 /etc/snort && \
chmod -R 5775 /var/log/snort && \
chmod -R 5775 /var/log/snort/archived_logs && \
chmod -R 5775 /etc/snort/so_rules && \
chmod -R 5775 /usr/local/lib/snort_dynamicrules && \

# Change Ownership on folders:
chown -R snort:snort /etc/snort && \
chown -R snort:snort /var/log/snort && \
chown -R snort:snort /usr/local/lib/snort_dynamicrules && \

#the commands below to move the files listed above to the /etc/snort folder:
cd ~/snort_src/snort-2.9.9.0/etc/ && \
cp *.conf* /etc/snort && \
cp *.map /etc/snort && \
cp *.dtd /etc/snort && \

cd ~/snort_src/snort-2.9.9.0/src/dynamic-preprocessors/build/usr/local/lib/snort_dynamicpreprocessor/ && \
cp * /usr/local/lib/snort_dynamicpreprocessor/ && \

cp /etc/snort/snort.conf /etc/snort/snort.conf.bak && \
cp /etc/snort/snort.conf.bak /etc/snort/snort.conf

# End Snort Install
# RUN Test as => snort -T -c /etc/snort/snort.conf

# Start Barnyard2 Install
WORKDIR /root/snort_src/

RUN wget https://github.com/firnsy/barnyard2/archive/v2-1.13.tar.gz -O barnyard2-2-1.13.tar.gz && \
tar zxvf barnyard2-2-1.13.tar.gz

WORKDIR /root/snort_src/barnyard2-2-1.13

RUN autoreconf -fvi -I ./m4 && \
./configure --with-mysql --with-mysql-libraries=/usr/lib/arm-linux-gnueabihf && \
#./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu && \
make -j3 && \
sudo make install && \
sudo ln -s /usr/include/dumbnet.h /usr/include/dnet.h && \
sudo ldconfig && \
sudo cp etc/barnyard2.conf /etc/snort && \
sudo mkdir /var/log/barnyard2 && \
sudo chown snort.snort /var/log/barnyard2 && \
sudo touch /var/log/snort/barnyard2.waldo && \
sudo chown snort.snort /var/log/snort/barnyard2.waldo && \
sudo touch /etc/snort/sid-msg.map


# End Barnyard2 Install

# Start Pulledpork Install
WORKDIR /root/snort_src/

RUN wget https://github.com/finchy/pulledpork/archive/66241690356d54faa509625a78f80f326b75c339.tar.gz -O pulledpork-0.7.2-194.tar.gz && \
tar xvfvz pulledpork-0.7.2-194.tar.gz && \
mv pulledpork-66241690356d54faa509625a78f80f326b75c339 pulledpork-0.7.2-194

WORKDIR /root/snort_src/pulledpork-0.7.2-194/

RUN sudo cp pulledpork.pl /usr/local/bin && \
sudo chmod +x /usr/local/bin/pulledpork.pl  && \
sudo cp etc/*.conf /etc/snort

# End Pulledpork Install

#ADD config files

ADD /config/snort.conf /etc/snort/snort.conf
ADD /config/barnyard2.conf /etc/snort/barnyard2.conf
ADD /config/pulledpork.conf /etc/snort/pulledpork.conf
RUN sudo chmod o-r /etc/snort/barnyard2.conf


WORKDIR /root
RUN sudo /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -l
RUN sudo snort -T -c /etc/snort/snort.conf
#ADD /config/run.sh /root/run.sh
#RUN sudo chmod +x /root/run.sh
#CMD ["/bin/sh", "-l", "-c", "/root/run.sh"]