package App::skryf::Login;
# TODO: move out of bootstrap
use Mojo::Base 'Mojolicious::Controller';

sub login {
  my $self = shift;
  $self->render('login');
}

sub logout {
  my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('splashpage');
}

sub auth {
    my $self = shift;
    my $user = $self->param('email');
    my $pass = $self->param('password');

    my $model =
      $self->store('User');
    if ($model->check($user, $pass)) {
        $self->flash(message => 'authenticated.');
        $self->session(user => 1);
        $self->session(username => $user);
        $self->redirect_to('admin_dashboard');
    } else {
      $self->flash(message => 'failed auth.');
      $self->redirect_to('login');
    }
}

1;
