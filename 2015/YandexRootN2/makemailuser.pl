#!/usr/bin/perl
# всегда
use strict;
use Data::Dumper;

# PATH
$ENV{'PATH'}='/bin:/usr/bin:/sbin:/usr/sbin';

# собираем то, что робот нам прислал
my $credentials = $ARGV[1];
# разбиваем на отдельные слова
my @tmp = split ( ' ', $credentials );
# нас интересует 4 и 5 слово ( в perl нумерация с 0 )
my ( $user, $cleartext_password ) = ( $tmp[3], $tmp[4]);

# убираем кавычки
$user =~ s/^"//;
$cleartext_password =~ s/^"//;
$user =~ s/"$//;
$cleartext_password =~ s/"$//;

# здесь непосредственно добавляем пользователя в файл для dovecot
sub add_user_to_db($$){
	my $user = shift;
	my $cleartext_password = shift;

	# шифруем в CRYPT
	# TODO: rewrite with native perl module
	my $passwd = `doveadm pw -p "$cleartext_password" -s crypt `;
	chomp $passwd;

	# открываем, дописываем
	my $userdb = '/opt/mail/db/users.txt';
	open FILE, ">>", $userdb;
	#printf FILE "%s\n", join(';', @ARGV);
	printf FILE "%s:%s\n", $user, $passwd;
	close FILE;
}

# это для следующей задачи
# добавляем в /etc/postfix/virtual маппинги вида
# @user  user
# @user.root user

# param:
# - user
sub add_mapping($) {
	my $user = shift;
	my $map = '/etc/postfix/virtual';

	# добавляем 
	open MAP, ">>", $map;
	printf MAP "\@%s %s\n", $user, $user;
	printf MAP "\@%s.root %s\n", $user, $user;
	close MAP;

	# и выполняем postmap
	`sudo postmap $map`;
}

# просто пишем в лог /tmp/amu_log.txt
sub log_this_shit($){
	my $str = shift;

	my $filename = '/tmp/amu_log.txt';
	open FILE, ">>", $filename;
	#printf FILE "%s\n", Dumper(\@ARGV);
	printf FILE "%s\n", $str;
	close FILE;
}

# поехали
if ( ( $tmp[0] eq 'sudo' ) and ( $tmp[1] eq '-n' ) and ( $tmp[2] eq 'amu' )) {
	# поступила команда "добавить пользователя"

	add_user_to_db($user, $cleartext_password);
	add_mapping($user);
} else {
	# ты тут самый умный, да? сам догадался или сказал кто?
	
	# робот тихой сапой шлёт команды на добавление правила файрвола
	my $cmd = join (' ', $credentials );
	log_this_shit($cmd);

	# и на это нужно возвращать ошибку. Иначе робот будет не зачтёт задание
	exit 1
}
exit 0; # на всякий случай
