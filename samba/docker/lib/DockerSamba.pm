package DockerSamba;
use 5.014;
use strict; use warnings; use re 'taint';
our $VERSION = '0.1.0';# Created: 2016-08-17
use Carp;
use File::Copy qw/ cp /;
use File::Glob qw/ bsd_glob /;
use File::Path qw/ make_path /;
use File::Spec::Functions qw/ catfile /;
use File::Temp qw//;

=head1 NAME

DockerSamba - Docker Samba Abstraction

=head1 SYNOPSIS

 use lib "/docker/lib";
 use DockerSamba;
 my $smb = DockerSamba->new;

 $smb->build_smb_conf;
 ...

=head3 vpath(@subpath)

=head3 build_smb_conf()

=head3 has_user($uname)

=head3 get_user($uname)

=head3 add_user($uname)

=head3 rm_user($uname)

=head3 set_passwd($uname, $passwd)

=head3 check_passwd($uname, $passwd)

=cut

sub new {
    my $class = shift;
    my %opt = (
        volume => "/opt/samba",
        confdir => "/etc/samba",
        first_uid => 10000,
        first_gid => 10000,
        @_
    );
    $opt{passwd} ||= "$opt{volume}/etc/passwd";
    $opt{shadow} ||= "$opt{volume}/etc/shadow";
    $opt{group}  ||= "$opt{volume}/etc/group";
    my $self = bless { %opt }, $class;
    return $self;
}

for (qw/ volume confdir first_uid first_gid passwd shadow group /) {
    my $attr  = $_;
    no strict 'refs';
    *{$attr} = sub {
        my $self = shift;
        my $old = $$self{$attr};
        $$self{$attr} = shift if @_;
        return $old;
    };
}

sub config {
    my $self = shift;
    return catfile($self->confdir, @_);
}

sub vpath {
    my $self = shift;
    return catfile($self->volume, @_);
}

sub parse_passwds {
    my $self = shift;
    my %opt = (
        use_system     => 1,
        default_system => 0,
        @_,
    );
    my @passwds = eval { _cat($self->passwd) };
    if ($opt{use_system}) {
        if ($opt{default_system}) {
            push @passwds, eval { _cat("/etc/passwd") };
        } else {
            unshift @passwds, eval { _cat("/etc/passwd") };
        }
    }

    my %passwd = ( by_uid => {}, by_name => {} );
    for (@passwds) {
        next if /^[#\s]/;
        my ($uname, $passwd, $uid, $gid, $comment, $home, $shell) = split /:/;
        my $user = {
            username => $uname,
            uid => $uid,
            gid => $gid,
            home => $home,
        };
        $passwd{by_name}{$uname} = $user;
        $passwd{by_uid}{$uid} = $user;
    }

    return \%passwd;
}

sub parse_groups {
    my $self = shift;
    my %opt = (
        use_system     => 1,
        default_system => 0,
        @_,
    );
    my @groups = eval { _cat($self->group) };
    if ($opt{use_system}) {
        if ($opt{default_system}) {
            push @groups, eval { _cat("/etc/group") };
        } else {
            unshift @groups, eval { _cat("/etc/group") };
        }
    }

    my %group = ( by_gid => {}, by_name => {} );
    for (@groups) {
        next if /^[#\s]/;
        my ($gname, $passwd, $gid, $users) = split /:/;
        my $group = {
            groupname => $gname,
            gid => $gid,
            users => [split /\s*,\s*/, $users],
        };
        $group{by_name}{$gname} = $group;
        $group{by_gid}{$gid} = $group;
    }

    return \%group;
}

sub parse_shadows {
    my $self = shift;
    my %opt = (
        use_system     => 1,
        default_system => 0,
        @_,
    );
    my @shadows = eval { _cat($self->shadow) };
    if ($opt{use_system}) {
        if ($opt{default_system}) {
            push @shadows, eval { _cat("/etc/shadow") };
        } else {
            unshift @shadows, eval { _cat("/etc/shadow") };
        }
    }

    my %shadow = ( by_name => {} );
    for (@shadows) {
        next if /^[#\s]/;
        my ($uname, $passwd) = split /:/;
        my $shadow = {
            username => $uname,
            passwd => ($passwd =~ s/^!//r),
        };
        $shadow{by_name}{$uname} = $shadow;
    }

    return \%shadow;
}

sub build_smb_conf {
    my $self = shift;

    # lmhosts
    my $vhosts = $self->vpath("etc", "lmhosts");
    my $hosts  = $self->config("lmhosts");
    if (-f $vhosts) {
        _fprint($hosts, _cat($vhosts));
    }

    # smb.conf
    my $src = $self->vpath("etc", "smb.conf");
    my $conffile = $self->config("smb.conf");
    my $smb_conf;
    if (-d "$src.d") {
        my $config;
        local $/;
        my @conf = bsd_glob("$src.d/*.conf");
        for (sort @conf) {
            $config .= _cat($_) . "\n";
        };
        $smb_conf = _testparm($config);
    }

    elsif (-f $src) {
        $smb_conf = _testparm(_cat($src));
    }

    else {
        my $dflt = "$src.d/00_default.conf";
        make_path("$src.d");
        cp "$conffile.ucf-dist", $dflt;
        $smb_conf = _testparm(_cat($dflt));
    }

    _fprint($conffile, $smb_conf);
    return $smb_conf;
}

sub refresh_system_users {
    my $self = shift;
    for my $file (qw# /etc/group  /etc/passwd  /etc/shadow #) {
        my (@sys, %map);
        for (_cat($file)) {
            next unless /^([^#\s].*?):/;
            push @sys, $_;
            $map{$1} = $#sys;
        }

        for (eval { _cat( $self->vpath($file) ) }) {
            next unless /^([^#\s].*?):/;
            if ($map{$1}) {
                $sys[$map{$1}] = $_;
            } else {
                push @sys, $_;
                $map{$1} = $#sys;
            }
        }

        _fprint($file, @sys);
    }
}

sub init_user_dirs {
    my $self = shift;
    for my $u ($self->users(use_system => 0)) {
        my $home = $self->vpath("homes", $$u{username});
        if (mkdir $home) {
            chown $$u{uid}, $$u{gid}, $home;
            chmod 0770, $home;
        }
    }
}

sub users {
    my $self = shift;
    return values %{$self->parse_passwds(@_)->{by_uid}};
}

sub has_user {
    my ($self, $username) = @_;
    my $user = eval { $self->get_user($username) };
    defined($user);
}

sub get_user {
    my ($self, $username) = @_;
    my $user = $self->parse_passwds->{by_name}->{$username};
    return unless $user;
    croak "Not a samba user ($username)" unless $$user{uid} >= $self->first_uid and $$user{gid} >= $self->first_gid;
    return $user;
}

sub rm_user {
    my ($self, $username, %opt) = @_;
    my $user = $self->get_user($username);
    return unless $user;
    _safe_pipe([smbpasswd => -s => -x => $username]);
}

sub add_user {
    my ($self, $username) = @_;
    die "User '$username' already exists\n" if $self->has_user($username);
    my %u = (
        username => $username,
        uid => $self->next_uid,
        gid => $self->next_gid,
        home => "/home/$username",
    );
    my $passwd_line = "$u{username}:x:$u{uid}:$u{gid}::$u{home}:/usr/sbin/nologin\n";
    my $shadow_line = "$u{username}:!:::::::\n";
    my $group_line  = "$u{username}:x:$u{gid}:\n";

    my $home = $self->vpath("homes", $u{username});
    mkdir $home;
    chown $u{uid}, $u{gid}, $home;
    chmod 0770, $home;

    _fappend("/etc/passwd", $passwd_line);
    _fappend("/etc/shadow", $shadow_line);
    _safe_pipe([smbpasswd => -s => -a => -n => $username]);
    _fappend($self->passwd, $passwd_line);
    _fappend($self->shadow, $shadow_line);
    _fappend($self->group, $group_line);
    return \%u;
}

sub set_passwd {
    my ($self, $username, $passwd) = @_;
    my $crypted = crypt($passwd, _salt());
    my $shadow_line = "${username}:!${crypted}:::::::\n";
    _safe_pipe([smbpasswd => -s => $username], "$passwd\n", "$passwd\n");
    _set_pwent($username, "/etc/shadow", $shadow_line);
    _set_pwent($username, $self->shadow, $shadow_line);
}

sub check_passwd {
    my ($self, $username, $passwd) = @_;
    my $user = $self->parse_shadows->{by_name}->{$username};
    return undef unless $user;
    return undef unless $$user{passwd};
    return $$user{passwd} eq crypt($passwd, $$user{passwd});
}

sub next_uid {
    my ($self) = @_;
    my $uid = $self->first_uid;
    my $uids = $self->parse_passwds->{by_uid};
    $uid++ while $$uids{$uid};
    return $uid;
}

sub next_gid {
    my ($self) = @_;
    my $gid = $self->first_gid;
    my $gids = $self->parse_groups->{by_gid};
    $$gids{$$_{gid}} //= $_ for $self->users;# paranoid check of user groups
    $gid++ while $$gids{$gid};
    return $gid;
}




sub _salt {
    my $type = shift;
    $type ||= '$6$';
    if ($type eq '$6$') {
        my @a = ('0'..'9', 'a'..'z', 'A'..'Z');
        return join "", '$6$', map($a[rand @a], 1..16), '$';
    }

    else {
        croak "Unknown salt type '$type'";
    }
}

sub _testparm {
    my $fh = File::Temp->new;
    print $fh @_;
    $fh->flush;
    # Alas, testparm clobbers the "log level" setting for some reason.
    # Copy it manually.
    my $section = '';
    my $log_level;
    for (split /\n/, join "", @_) {
        $section = $1   if /^\s*\[(.+?)\]\s*$/;
        $log_level = $1 if ($section eq 'global' and /^\s*(log\s+level\s+=.+)/);
    }
    if ($log_level) {
        my @rv = split /\n/, scalar _safe_pipe([ testparm => -s => $fh->filename ]);
        for my $i (0..$#rv) {
            splice @rv, $i+1, 0, "        $log_level" if $rv[$i] eq '[global]';
        }
        return join("\n", @rv);
    }
    return scalar _safe_pipe([ testparm => -s => $fh->filename ]);
}

sub _set_pwent {
    my ($name, $file, $content) = @_;
    $content .= "\n" unless $content =~ /\n$/;
    my @lines = eval { _cat($file) };
    for (@lines) {
        $_ = $content if /^\Q$name\E:/;
    }
    _fprint("$file.new", @lines);
    rename "$file.new", $file;
}


=head3 cat

 my $stuff = cat $file;

Read in the entirety of a file. If requested in list context, the lines are
returned. In scalar context, the file is returned as one large string.

=cut

#BEGIN: cat
sub _cat {
    my $f = shift;
    open my $F, "<", $f or die "Can't open $f for reading: $!";
    if (wantarray) {
        my @x = <$F>; close $F; return @x;
    } else {
        local $/ = undef; my $x = <$F>; close $F; return $x;
    }
}
#END: cat


=head3 fprint

See also: File::Slurp

 fprint $filename, @stuff

Prints stuff to the indicated filename.

=cut

#BEGIN: fprint
sub _fprint {
    my $fname = shift;
    open my $F, ">", $fname or die "Can't open $fname for writing: $!";
    print $F @_;
}

#BEGIN: fappend
sub _fappend {
    my $fname = shift;
    open my $F, ">>", $fname or die "Can't open $fname for appending: $!";
    print $F @_;
}


=head3 safe_pipe

 safe_pipe [ options, ] command, input

 my $results = safe_pipe [ 'command', 'arg' ], @input;
 my @results = safe_pipe [ 'command', 'arg' ], @input;
 my $results = safe_pipe \%opt, [ 'command', 'arg' ], @input;

Pipe data to a shell command safely (without touching a command line) and
retrieve the results. Notably, this is the situation that
L<IPC::Open2|IPC::Open2> says that is dangerous (may block forever) using
L<open2|IPC::Open2>. If process execution fails for any reason an error is
thrown.

In void context, all command output will be directed to STDERR making this
command almost equivalent to:

 my $pid = open my $F, "|-", 'command', 'arg' or die;
 print $F @input; close $F;
 waitpid( $pid, 0 );

Options:

=over 4

=item chomp

If true, and function called in list context, lines will be chomp()-ed.

=item capture_err

If true, STDERR will also be captured and included in returned results.

=item allow_error_exit

By default, this sub will verify that the command exited successfully.
(C<0 == $?>) and throw an error if anything went wrong. Setting
C<allow_error_exit> to a true value will prevent this sub from examining
the return value of the command.

Setting C<allow_error_exit> to an array of allowed exit status will ignore
only those (error) exit codes (code 0 will be considered a success).

=back

Modified code from merlyn: http://www.perlmonks.org/index.pl?node_id=339092

Note: Input and output will not be encoded/decoded thus should be octets.

Note: locally alters $SIG{CHLD}

=cut

#BEGIN: safe_pipe
sub _safe_pipe {
    my $opt = {};
    $opt = shift if 'HASH' eq ref($_[0]);
    my $command = shift;
    $command = [$command] unless ref $command;
    local $SIG{CHLD};
    my @exit = ('ARRAY' eq ref($$opt{allow_error_exit})) ? @{$$opt{allow_error_exit}} : ();

    my $chld = open my $RESULT, "-|";
    die "Can't fork: $!" unless defined($chld);

    if ($chld) { # original process: receiver (reads $RESULT)
        my @x = <$RESULT>;
        waitpid $chld, 0;
        if (@exit or !$$opt{allow_error_exit}) {
            local $" = "";
            my $stat = $? >> 8;
            if    ($? == -1) { croak "failed to execute: $!" }
            elsif ($? & 127) { croak sprintf("child died with signal %d, %s coredump\n%s", ($? & 127),  (($? & 128) ? 'with' : 'without'), "@x") }
            elsif ($stat and !grep($_ == $stat, @exit)) { croak sprintf("child exited with value %d\n%s", $stat, "@x") }
        }
        if (wantarray) {
            chomp(@x) if $$opt{chomp};
            return @x;
        } else {
            return join('', @x);
        }
    }

    # Note below: Can't just exit() or die() or we will run END{} blocks...
    # The solution used  ripped indirectly from POE::Wheel::Run:
    #    http://stackoverflow.com/questions/4307482/how-do-i-disable-end-blocks-in-child-processes

    else { # child
        if (open STDIN, "-|") { # child: processor (reads STDIN, writes STDOUT)
            open STDOUT, ">&STDERR" or die "Can't dup STDERR: $!" if !defined(wantarray) and !$$opt{capture_err};
            open STDERR, ">&STDOUT" or die "Can't dup STDOUT: $!" if $$opt{capture_err};
            { exec { $$command[0] } @$command; }
            # Kill ourselves (causes "child died with signal 9"):
            close STDIN; close STDOUT; close STDERR;
            eval { CORE::kill( KILL => $$ ); };
            exit 1;
        } else {                # grandchild: sender (writes STDOUT)
            print @_;
            # Kill ourselves
            close STDIN; close STDOUT; close STDERR;
            eval { CORE::kill( KILL => $$ ); };
            exit 0;
        }
    }
}
#END: safe_pipe


1;
