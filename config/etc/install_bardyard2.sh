#intsall mysql plugin tools
#apt-get install -y libmysqlclient-dev mysql-client autoconf libtool

cd ~/snort_src

wget https://github.com/firnsy/barnyard2/archive/v2-1.13.tar.gz -O barnyard2-2-1.13.tar.gz
tar zxvf barnyard2-2-1.13.tar.gz

cd barnyard2-2-1.13

autoreconf -fvi -I ./m4
./configure --with-mysql --with-mysql-libraries=/usr/lib/arm-linux-gnueabihf && \
make -j3 && \
sudo make install

sudo ln -s /usr/include/dumbnet.h /usr/include/dnet.h
sudo ldconfig

cd ~/snort_src/barnyard2-2-1.13
sudo cp etc/barnyard2.conf /etc/snort
 
# the /var/log/barnyard2 folder is never used or referenced
# but barnyard2 will error without it existing
sudo mkdir /var/log/barnyard2
sudo chown snort.snort /var/log/barnyard2
 
sudo touch /var/log/snort/barnyard2.waldo
sudo chown snort.snort /var/log/snort/barnyard2.waldo
sudo touch /etc/snort/sid-msg.map

# ADD 'ADD' Dockerfile barnyard2.conf
sudo chmod o-r /etc/snort/barnyard2.conf