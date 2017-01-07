#!/bin/bash

cd /var/www/html/pf-test
ln -s /usr/local/paraframe/share/html/pf pf
cd /usr/local/paraframe
mkdir /tmp/pf_demo
chmod 02770 /tmp/pf_demo
chgrp staff /tmp/pf_demo
./demo/demoserver.pl //localhost:7788/pf-test
apache2ctl start
