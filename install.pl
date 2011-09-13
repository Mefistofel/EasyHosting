#!/usr/local/bin/perl
system "aptitude update";
system "aptitude install -y mysql-server apache2 apache2-suexec libapache2-mod-fcgid php5  php5-mysql php5-cgi vsftpd";
system "a2dismod php5";
system "a2enmod suexec";
#system "mkdir /var/www/httpd-logs";
#system "addgroup secure";
#system "echo \"/bin/date\" >> /etc/shells";
open (FCGI, '>/etc/apache2/mods-available/fcgid.conf');
print FCGI "<IfModule mod_fcgid.c>
    AddHandler    fcgid-script .fcgi
    FcgidConnectTimeout 20
    MaxRequestLen 15728640
</IfModule>
";
close (FCGI);
open (VSFTP, '>>/etc/vsftpd.conf');
print VSFTP "rsa_cert_file=/etc/ssl/private/vsftpd.pem
chroot_local_user=YES
local_enable=YES
force_dot_files=YES
background=YES
anonymous_enable=NO
";
close (VSFTP);
system "service apache2 restart";
system "service vsftpd restart";
