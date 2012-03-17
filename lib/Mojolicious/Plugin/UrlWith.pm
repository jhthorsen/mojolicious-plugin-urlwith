package Mojolicious::Plugin::UrlWith;

=head1 NAME

Mojolicious::Plugin::UrlWith - Preserve parts of the url

=head1 VERSION

0.05

=head1 DESCRIPTION

This helper provides the same method as L<Mojolicious::Controller/url_for>
with the difference that it keeps the query string.

=head1 SYNOPSIS

    package MyApp;
    sub startup {
        my $self = shift;

        $self->plugin('Mojolicious::Plugin::UrlWith' => {
            parse_fragment => 1,
            current_page_class => 'current-page',
        });

        # ...
    }

=cut

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw/ xml_escape /;
use Mojolicious::Plugin::TagHelpers;

our $VERSION = eval '0.05';

=head1 ATTRIBUTES

=head2 parse_fragment

Will remove the '#fragment' part from the first arugment to L</url_with>,
and use it use it for L<Mojo::URL/fragment>.

=cut

__PACKAGE__->attr(parse_fragment => sub { 0 });

=head2 current_page_class

    $self->current_page_class($classname);
    $classname = $self->current_page_class;

Will add the C<$classname> to the link in L</link_with> if the path part
of the link match the currently requested path. You need to set this
attribute when registering the plugin, since the default value is empty
string, cancelling the behavior.

This attribute is EXPERIMENTAL and may be removed/changed without warning.

=cut

__PACKAGE__->attr(current_page_class => sub { '' });

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

=item $controller->url_with('/path', [ c => 313 ]);

Will result in C<http://somedomain.com/path?c=313>.

=back

Summary: A hash-ref will be merged with existing query params, while
an array-ref will create a new set of query params.

=cut

sub url_with {
    my $self = shift;
    my $controller = shift;
    my $args = ref($_[-1]) =~ /^(?:HASH|ARRAY)$/ ? pop : undef;
    my @args = @_;
    my $query = $controller->req->url->query->clone;
    my $url;

    if($self->parse_fragment) {
        if(defined $_[0] and ref $_[0] eq '') {
            $args[0] =~ s/#(.*)$//;
            $url = $controller->url_for(@args);
            $url->fragment($1);
        }
    }
    if(!$url) {
        $url = @args ? $controller->url_for(@args) : $controller->req->url->clone;
    }

    if(ref $args eq 'HASH') { # merge
        for my $key (keys %$args) {
            if(defined $args->{$key}) {
                $query->param($key => $args->{$key});
            }
            else {
                $query->remove($key);
            }
        }
    }
    elsif(ref $args eq 'ARRAY') { # replace
        $query = Mojo::Parameters->new(@$args);
    }

    $url->query($query);

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
    my($url, @url_args, @tag_args);

    # Pretty much copy/paste from Plugin::TagHelpers
    unless(defined $_[-1] and ref $_[-1] eq 'CODE') {
        my $content = shift;
        xml_escape $content;
        push @tag_args, sub { $content };
    }

    for my $i (reverse 0..@_-1) {
        if(ref($_[$i]) =~ /^(?:HASH|ARRAY)/) {
            push @url_args, @_[0..$i];
            unshift @tag_args, @_[$i+1..@_-1];
            last;
        }
    }

    $url = $self->url_with($controller, @url_args);

    if(my $class = $self->current_page_class) {
        if($url->path eq $controller->req->url->path) {
            unshift @tag_args, class => $class;
        }
    }

    return Mojolicious::Plugin::TagHelpers->_tag(a => href => $url, @tag_args);
}

=head1 METHODS

=head2 register

Will register the methods under L</HELPERS>.

=cut

sub register {
    my($self, $app, $config) = @_;

    $config->{'url_with_alias'} ||= 'url_with';
    $config->{'link_with_alias'} ||= 'link_with';
    $self->parse_fragment($config->{'parse_fragment'} || 0);
    $self->current_page_class($config->{'current_page_class'} || '');

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
