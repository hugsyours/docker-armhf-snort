#Install the PulledPork pre-requisites
#sudo apt-get install -y libcrypt-ssleay-perl liblwp-useragent-determined-perl

cd ~/snort_src
wget https://github.com/finchy/pulledpork/archive/66241690356d54faa509625a78f80f326b75c339.tar.gz -O pulledpork-0.7.2-194.tar.gz
tar xvfvz pulledpork-0.7.2-194.tar.gz
mv pulledpork-66241690356d54faa509625a78f80f326b75c339 pulledpork-0.7.2-194
 
#Download PulledPork and install:
cd pulledpork-0.7.2-194/
sudo cp pulledpork.pl /usr/local/bin
sudo chmod +x /usr/local/bin/pulledpork.pl
sudo cp etc/*.conf /etc/snort

# Import configfile
# /config/pulledpork.conf    to /etc/snort/pulledpork.conf
# /config/snort.conf         to /etc/snort/snort.conf
# /config/barnyard2.conf     to /etc/snort/barnyard2.conf