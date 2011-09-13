#########
# V 1.0 #
#########
print "USER:";
$user = <STDIN>;
chomp $user;
print "DOMAIN:";
$domain = <STDIN>;
chomp $domain;
system "mkdir /var/www/$user";
system "useradd $user -d /var/www/$user/data -m -s /bin/date";
system "mkdir /var/www/$user/data/php-bin";
system "mkdir /var/www/$user/data/bin-tmp";
system "mkdir /var/www/$user/data/logs";
system "touch /var/www/$user/data/logs/php_errors.log";
system "mkdir /var/www/$user/data/www";
system "mkdir /var/www/$user/data/www/$domain";
system "echo \"\#\!/usr/bin/php5-cgi\" > /var/www/$user/data/php-bin/php";
system "chmod 501 /var/www/$user/data/php-bin/php";
system "chmod 777 /var/www/$user/data/bin-tmp";
open (FILE, '>>/etc/apache2/apache2.conf') or die $!;
print FILE "
<VirtualHost *:80>
    ServerName $domain
    DocumentRoot /var/www/$user/data/www/$domain
    SuexecUserGroup $user $user
    CustomLog /var/www/httpd-logs/$domain.access.log combined
    ErrorLog /var/www/httpd-logs/$domain.error.log
    ServerAlias www.$domain
    ServerAdmin webmaster@$domain
    ScriptAlias /cgi-bin/ /var/www/$user/data/www/$domain/cgi-bin/
    AddHandler fcgid-script .php .php3 .php4 .php5 .phtml
</VirtualHost>
<Directory /var/www/$user/data/www/$domain>
    FCGIWrapper /var/www/$user/data/php-bin/php .php
    FCGIWrapper /var/www/$user/data/php-bin/php .php3
    FCGIWrapper /var/www/$user/data/php-bin/php .php4
    FCGIWrapper /var/www/$user/data/php-bin/php .php5
    FCGIWrapper /var/www/$user/data/php-bin/php .phtml
    Options +ExecCGI
</Directory>
";
close (FILE);
open (INI, ">/var/www/$user/data/php-bin/php.ini") or die $!;
print INI "
sendmail_path = \"/usr/sbin/sendmail -t -i -f webmaster\@$domain\"
session.save_path = \"/var/www/$user/data/bin-tmp\"
max_execution_time= 30
memory_limit= 32M
upload_max_filesize= 10M
post_max_size= 10M
disable_functions = \"ini_alter, curl_exec, exec, system, passthru, shell_exec, proc_open, proc_close, proc_get_status, proc_nice, proc_terminate, leak, listen, chgrp, apache_note, apache_setenv, closelog, debugger_off, debugger_on, define_sys log_variables, openlog, syslog,ftp_exec,dl, phpinfo, popen, chgrp, curl_exec, listen posix_getegid, posix_geteuid, posix_getpwuid, posix_kill, posix_mkfifo, posix_setpgid, posix_setsid, posix_setuid, posix_uname\" 
safe_mode = Off
register_globals = Off
expose_php = Off
display_errors = Off
display_startup_errors = Off
log_errors = On
error_reporting = E_ALL
error_log = \"/var/www/$user/data/logs/php_errors.log\"
magic_quotes_gpc = On
magic_quotes_sybase = Off
";
close (INI);
system "service apache2 restart";
system "ln /var/www/httpd-logs/$domain.error.log /var/www/$user/data/logs/";
system "ln /var/www/httpd-logs/$domain.access.log /var/www/$user/data/logs/";
system "chmod 501 /var/www/$user";
system "chown -R $user:$user /var/www/$user";
system "chmod 751 /var/www/$user/data/www/$domain";
system "cat /dev/urandom| tr -dc 'a-zA-Z0-9' | fold -w 10| head -n 1";
system "passwd $user";
