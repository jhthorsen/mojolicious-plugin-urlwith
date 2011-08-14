use warnings;
use strict;
use lib qw(lib);
use Test::More;
use Test::Mojo;
use Mojolicious::Lite;

my $t = Test::Mojo->new;

plan tests => 12;
plugin 'url_with';

get '/echo1' => sub { $_[0]->render(text => $_[0]->url_with({})->to_string) };
get '/echo2' => sub { $_[0]->render(text => $_[0]->url_with->to_string) };
get '/search-add' => sub { $_[0]->render(text => $_[0]->url_with({ name => 'bob' })->to_string) };
get '/search-undef' => sub { $_[0]->render(text => $_[0]->url_with({ page => undef })->to_string) };
get '/name' => sub { $_[0]->render(text => $_[0]->url_with(somenamedroute => { age => 42 })->to_string) };
get '/path' => sub { $_[0]->render(text => $_[0]->url_with('/path' => { random => 24 })->to_string) };
get '/some/named/route' => sub {};

$t->get_ok('/echo1?page=1')->content_is('/echo1?page=1');
$t->get_ok('/echo2?page=1')->content_is('/echo2?page=1');
$t->get_ok('/search-add?page=1')->content_is('/search-add?page=1&name=bob');
$t->get_ok('/search-undef?page=1')->content_is('/search-undef');
$t->get_ok('/name?page=1')->content_is('/some/named/route?page=1&age=42');
$t->get_ok('/path?page=1')->content_is('/path?page=1&random=24');
