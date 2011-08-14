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
use Mojo::Util qw/ xml_escape /;
use Mojolicious::Plugin::TagHelpers;

our $VERSION = '0.01';

=head1 HELPERS

=head2 url_with

The examples below has this current request url:
C<http://somedomain.com/search?page=1>.

=over 4

=item $controller->url_with({ name => 'bob' });

Will result in C<http://somedomain.com/search?page=1&name=bob>.

=item $controller->url_with({ page => undef });

Will result in C<http://somedomain.com/search>.

=item $controller->url_with('named', { age => 42 });

Will result in C<http://somedomain.com/some/named/route?page=1&age=42>.

=item $controller->url_with('/path', { random => 24 });

Will result in C<http://somedomain.com/path?page=1&random=24>.

=back

=cut

sub url_with {
    my $self = shift;
    my $controller = shift;
    my $args = ref $_[-1] eq 'HASH' ? pop : {};
    my $url = @_ ? $controller->url_for(@_) : $controller->req->url->clone;
    my $query = $controller->req->url->query->clone;

    $url->query($query);

    for my $key (keys %$args) {
        if(defined $args->{$key}) {
            $query->append($key => $args->{$key});
        }
        else {
            $query->remove($key);
        }
    }

    return $url;
}

=head2 link_with

Same as L<Mojolicious::Plugin::TagHelpers/link_to>, but use L</url_with>
instead of L<Mojolicious::Controller/url_to> to construct the hyper
reference.

=cut

sub link_with {
    my $self = shift;
    my $controller = shift;
    my(@url_args, @tag_args);

    # Pretty much copy/paste from Plugin::TagHelpers
    unless(defined $_[-1] and ref $_[-1] eq 'CODE') {
        my $content = shift;
        xml_escape $content;
        push @tag_args, sub { $content };
    }

    for my $i (reverse 0..@_-1) {
        if(ref $_[$i] eq 'HASH') {
            push @url_args, @_[0..$i];
            unshift @tag_args, @_[$i+1..@_-1];
            last;
        }
    }

    return Mojolicious::Plugin::TagHelpers->_tag(
        a => href => $self->url_with($controller, @url_args),
        @tag_args,
    );
}

=head1 METHODS

=head2 register

Will register the methods under L</HELPERS>.

=cut

sub register {
    my($self, $app, $config) = @_;

    $config->{'url_with_alias'} ||= 'url_with';
    $config->{'link_with_alias'} ||= 'link_with';

    $app->helper($config->{'url_with_alias'} => sub { $self->url_with(@_) });
    $app->helper($config->{'link_with_alias'} => sub { $self->link_with(@_) });
}

=head1 COPYRIGHT & LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
