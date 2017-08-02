#make director for snort
#mkdir /root/snort_src
cd /root/snort_src/

#install DAQ 2.0.6
wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz
tar -xvzf daq-2.0.6.tar.gz && cd daq-2.0.6 && ./configure && make -j3 && sudo make install

cd /root/snort_src

#install snort 2.9.9.0
wget https://www.snort.org/downloads/snort/snort-2.9.9.0.tar.gz
tar -xvzf snort-2.9.9.0.tar.gz && cd snort-2.9.9.0 && ./configure --enable-sourcefire && make -j3 && sudo make install

cd /root/snort_src

ldconfig
sudo ln -s /usr/local/bin/snort /usr/sbin/snort
/usr/sbin/snort -V

#Add user "snort" and groupadd "snort"
groupadd snort
useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort

# Create the Snort directories:
mkdir /etc/snort
mkdir /etc/snort/rules
mkdir /etc/snort/rules/iplists
mkdir /etc/snort/preproc_rules
mkdir /usr/local/lib/snort_dynamicrules
mkdir /etc/snort/so_rules

# Create some files that stores rules and ip lists
touch /etc/snort/rules/iplists/default.blacklist
touch /etc/snort/rules/iplists/default.whitelist
touch /etc/snort/rules/local.rules

# Create our logging directories:
mkdir /var/log/snort
mkdir /var/log/snort/archived_logs

# Adjust permissions:
chmod -R 5775 /etc/snort
chmod -R 5775 /var/log/snort
chmod -R 5775 /var/log/snort/archived_logs
chmod -R 5775 /etc/snort/so_rules
chmod -R 5775 /usr/local/lib/snort_dynamicrules

# Change Ownership on folders:
chown -R snort:snort /etc/snort
chown -R snort:snort /var/log/snort
chown -R snort:snort /usr/local/lib/snort_dynamicrules

#the commands below to move the files listed above to the /etc/snort folder:
cd ~/snort_src/snort-2.9.9.0/etc/
cp *.conf* /etc/snort
cp *.map /etc/snort
cp *.dtd /etc/snort

cd ~/snort_src/snort-2.9.9.0/src/dynamic-preprocessors/build/usr/local/lib/snort_dynamicpreprocessor/
cp * /usr/local/lib/snort_dynamicpreprocessor/
sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf

cp /etc/snort/snort.conf /etc/snort/snort.conf.bak
cp /etc/snort/snort.conf.bak /etc/snort/snort.conf

#Set config "snort.conf"

file1="/etc/snort/snort.conf"

RULE_PATH_N="var RULE_PATH /etc/snort/rules"
SO_RULE_PATH_N="var SO_RULE_PATH /etc/snort/so_rules"
PREPROC_RULE_PATH_N="var PREPROC_RULE_PATH /etc/snort/preproc_rules"

WHITE_LIST_PATH_N="var WHITE_LIST_PATH /etc/snort/rules/iplists"
BLACK_LIST_PATH_N="var BLACK_LIST_PATH /etc/snort/rules/iplists"
IP_LIST_RULE_PATH="/etc/snort/rules/iplists"

WL_PULLEDPORK="default.whitelist"
BL_PULLEDPORK="default.blacklist"

sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf

sed -i "s#var RULE_PATH ../rules#$RULE_PATH_N#" "$file1"
sed -i "s#var SO_RULE_PATH ../so_rules#$SO_RULE_PATH_N#" "$file1"
sed -i "s#var PREPROC_RULE_PATH ../preproc_rules#$PREPROC_RULE_PATH_N#" "$file1"

sed -i "s#var WHITE_LIST_PATH ../rules# $WHITE_LIST_PATH_N#" "$file1"
sed -i "s#var BLACK_LIST_PATH ../rules# $BLACK_LIST_PATH_N#" "$file1"

sed -i "s#white_list.rules#$WL_PULLEDPORK#" "$file1"
sed -i "s#black_list.rules#$BL_PULLEDPORK#" "$file1"

touch $IP_LIST_RULE_PATH/$WL_PULLEDPORK
touch $IP_LIST_RULE_PATH/$BL_PULLEDPORK

snort -T -c /etc/snort/snort.conf
