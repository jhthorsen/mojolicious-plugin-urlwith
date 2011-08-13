package Mojolicious::Plugin::UrlWith;

=head1 NAME

Mojolicious::Plugin::UrlWith - Preserve parts of the url

=head1 VERSION

0.01

=head1 DESCRIPTION

This helper provides the same method as L<Mojolicious::Controller/url_for>
with the difference that it keeps the query string.

=head1 SYNOPSIS

    package MyApp;
    sub startup {
        my $self = shift;
        $self->plugin('Mojolicious::Plugin::UrlWith');
        # ...
    }

=cut

use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

=head1 HELPERS

=head2 url_with

The examples below has this current request url:
C<http://somedomain.com/search?page=1>.

=over 4

=item $new_url = $controller->url_with({ name => 'bob' });

Will result in C<http://somedomain.com/search?page=1&name=bob>.

=item $new_url = $controller->url_with({ page => undef });

Will result in C<http://somedomain.com/search>.

=item $new_url = $controller->url_with('named', { age => 42 });

Will result in C<http://somedomain.com/some/named/route?page=1&age=42>.

=item $new_url = $controller->url_with('/path', { random => 24 });

Will result in C<http://somedomain.com/path?page=1&random=24>.

=back

=cut

sub __url_with {
    my $controller = shift;
    my $args = ref $_[-1] eq 'HASH' ? pop : {};
    my $url = @_ ? $controller->url_for(@_) : $controller->req->url->clone;
    my $query = $controller->req->url->query->clone;

    $url->query($query);

    for my $key (keys %$args) {
        if(not defined $args->{$key}) {
            $query->remove($key);
        }
        else {
            $query->append($key => $args->{$key});
        }
    }

    return $url;
}

=head1 METHODS

=head2 register

Will register the methods under L</HELPERS>.

=cut

sub register {
    my($self, $app, $config) = @_;

    $app->helper(url_with => \&__url_with);
}

=head1 COPYRIGHT & LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
