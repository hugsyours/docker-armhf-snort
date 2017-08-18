rm /var/log/snort/snort.u2.*

sleep 1

/usr/local/bin/snort -u snort -g snort -c /etc/snort/snort.conf -i eth0 -D

sleep 1

barnyard2 -c /etc/snort/barnyard2.conf -d /var/log/snort -f snort.u2 -w /var/log/snort/barnyard2.waldo -g snort -u snort

sleep 1

exit
