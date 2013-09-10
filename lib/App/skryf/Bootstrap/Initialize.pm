package App::skryf;

use Mojo::Base 'Mojolicious';
use Class::Load ':all';
use App::skryf::Model::Base;

our $VERSION = '0.014_01';

has admin_menu => sub {
  my $self = shift;
  return [];
};

has frontend_menu => sub {
  my $self = shift;
  return [];
};

sub startup {
    my $self = shift;
###############################################################################
# Setup configuration
###############################################################################
    my $cfg = $self->home->rel_dir("app/config/skryf.conf");
    $cfg = $self->plugin('Config' => {file => $cfg});

    $self->helper(
        store => sub {
            my $self        = shift;
            my $model       = shift;
            my $store_class = sprintf("App::skryf::Plugin::%s", $model);
            try_load_class($store_class);
            return $store_class->new(dbname => $cfg->{dbname});
        }
    );

###############################################################################
# Load Command and Plugin Namespaces
###############################################################################
    push @{$self->commands->namespaces}, 'App::skryf::Command';
    push @{$self->plugins->namespaces},  'App::skryf::Plugin';

    $self->helper(
        site => sub {
            my $self = shift;
            $self->store('SiteConf')->get || +{};
        }
    );
    $self->secret($self->site->{secret} || 'lets dance!');

###############################################################################
# Load core plugins
###############################################################################
    foreach (@{$self->site->{core_plugins}}) {
        $self->plugin("$_");
    }

###############################################################################
# Additional plugins
###############################################################################
    foreach (@{self->site->{extra_plugins}}) {
        $self->plugin("$_");
    }

###############################################################################
# Include template and public paths
###############################################################################
    push @{$self->renderer->paths}, $self->home->rel_dir("app/templates");
    push @{$self->static->paths},   $self->home->rel_dir("app/public");

###############################################################################
# Routing
###############################################################################
    my $r = $self->routes;

    # Authentication
    # TODO: make pluggable
    $r->get('/login')->to('login#login')->name('login');
    $r->get('/logout')->to('login#logout')->name('logout');
    $r->post('/auth')->to('login#auth')->name('auth');

    # TODO: make splashpage overridable
    $r->get('/')->to(
        namespace => 'App::skryf::Plugin::Blog::Controller',
        action    => 'blog_splash'
    )->name('splashpage');
}
1;

__END__

=head1 NAME

App::Skryf - Perl CMS, because I was bored.

=head1 DESCRIPTION

CMS platform fore those who like to 'experiment' college days style.

=head1 INSTALLATION (BLEEDING EDGE)

    $ git clone git://github.com/battlemidget/App-skryf.git
    $ cd App-skryf
    $ ./vendor/bin/carton

This will bootstrap L<Carton> and installs all dependencies.

=head1 INSTALLATION (STABLE)

Download the latest stable release from L<https://github.com/battlemidget/App-skryf/releases>.
Once extracted run:

    $ ./vendor/bin/carton

This also bootstraps L<Carton> and installs all dependencies.

=head1 SETUP

    $ carton exec rex setup

=head1 RUN

    $ carton exec rex skryf

=head1 UPGRADING

    $ carton exec rex upgrade

This will download the latest bits keeping your existing configuration, templates, and assets
intact. You will be prompted to merge the configuration if necessary items are required to run
the latest release.

=head1 TIPS

=head2 MONITORING

In B<deploy/ubic/service> is an example B<ubic-skryf> for L<Ubic> that will help you
get started. Essentially place this wherever you have Ubic setup for services and
execute with:

    $ carton ubic start skryf

=head2 SERVING

There is an example site configuration in B<deploy/nginx/sites-available/skryf.app.conf>

=head1 AUTHOR

Adam Stokes E<lt>adamjs@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Adam Stokes

=head1 LICENSE

Licensed under the same terms as Perl.

=cut
