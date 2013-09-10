package App::skryf::Command::setup;

use Mojo::Base 'Mojolicious::Command';
use Mango::BSON ':bson';
use FindBin '$Bin';
use Carp;
use Term::Prompt;

has description => "Setup your cms\n";
has usage       => <<"EOF";

Usage: $0 setup

EOF

sub run {
    my ($cmd) = @_;
    my $site = $cmd->app->store('SiteConf');
    my $usermodel = $cmd->app->store('User');
    my %user_input;
    my %user_creds;
    $user_input{site} =
      prompt('x', '', 'Site URL', 'http://skryf.astokes.org');
    $user_input{title}   = prompt('x', '', 'Title',   'Skryf cms');
    $user_input{author}  = prompt('x', '', 'Author',  'Adam Stokes');
    $user_creds{contact} = prompt('x', '', 'Contact', 'adamjs@cpan.org');
    $user_creds{password} = prompt('x', '', 'Password', '');
    $user_input{description} = prompt('x', '', 'Description', 'A perl cms');
    $user_input{tz}     = prompt('x', '', 'Timezone', 'America/New_Yok');
    $user_input{secret} = prompt('x', '', 'Secret',   '');
    $user_input{core_plugins} =
      ['Admin', 'CSRFProtect'];
    $site->create(\%user_input);
    $usermodel->create($user_creds{contact}, $user_creds{password});
    say "";
    say "Setup complete.";
}

1;
