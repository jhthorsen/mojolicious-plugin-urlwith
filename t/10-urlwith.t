use warnings;
use strict;
use lib qw(lib);
use Test::More;
use Test::Mojo;
use Mojolicious::Lite;

my $t = Test::Mojo->new;

plan tests => 22;
plugin 'url_with';

get '/echo1' => sub { $_[0]->render(text => $_[0]->url_with({})->to_string) };
get '/echo2' => sub { $_[0]->render(text => $_[0]->url_with->to_string) };
get '/search-add' => sub { $_[0]->render(text => $_[0]->url_with({ name => 'Bob' })->to_string) };
get '/search-undef' => sub { $_[0]->render(text => $_[0]->url_with({ page => undef })->to_string) };
get '/name' => sub { $_[0]->render(text => $_[0]->url_with(somenamedroute => { age => 42 })->to_string) };
get '/path' => sub { $_[0]->render(text => $_[0]->url_with('/path' => { random => 24 })->to_string) };
get '/some/named/route' => sub {};
get '/cap/:a' => sub {};

get '/link-with' => sub { $_[0]->render(text => $_[0]->link_with('Link text')) };
get '/link-with-simple' => sub { $_[0]->render(text => $_[0]->link_with('Bob', { name => 'Bob' })) };
get '/link-with-text' => sub { $_[0]->render(text => $_[0]->link_with('Link text', '/path' => { age => 42 })) };
get '/link-with-sub' => sub { $_[0]->render(text => $_[0]->link_with(somenamedroute => { name => 'Bob' }, sub { 'Sub text' })) };
get '/link-with-cap' => sub { $_[0]->render(text => $_[0]->link_with(capa => { a => 42 }, { b => 24 }, sub { 'cap' })) };

$t->get_ok('/echo1?page=1')->content_is('/echo1?page=1');
$t->get_ok('/echo2?page=1')->content_is('/echo2?page=1');
$t->get_ok('/search-add?page=1')->content_is('/search-add?page=1&name=Bob');
$t->get_ok('/search-undef?page=1')->content_is('/search-undef');
$t->get_ok('/name?page=1')->content_is('/some/named/route?page=1&age=42');
$t->get_ok('/path?page=1')->content_is('/path?page=1&random=24');

$t->get_ok('/link-with?page=1')->content_is('<a href="/link-with?page=1">Link text</a>');
$t->get_ok('/link-with-simple?page=1')->content_is('<a href="/link-with-simple?page=1&amp;name=Bob">Bob</a>');
$t->get_ok('/link-with-text?page=1')->content_is('<a href="/path?page=1&amp;age=42">Link text</a>');
$t->get_ok('/link-with-sub?page=1')->content_is('<a href="/some/named/route?page=1&amp;name=Bob">Sub text</a>');
$t->get_ok('/link-with-cap?page=1')->content_is('<a href="/cap/42?page=1&amp;b=24">cap</a>');
