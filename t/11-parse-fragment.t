use warnings;
use strict;
use lib qw(lib);
use Test::More;
use Test::Mojo;
use Mojolicious::Lite;

my $t = Test::Mojo->new;

plan tests => 16;
plugin 'url_with', parse_fragment => 1;

get '/echo1' => sub { $_[0]->render(text => $_[0]->url_with({})->to_string) };
get '/echo2' => sub { $_[0]->render(text => $_[0]->url_with->to_string) };
get '/name' => sub { $_[0]->render(text => $_[0]->url_with('somenamedroute#list' => { age => 42 })->to_string) };
get '/path' => sub { $_[0]->render(text => $_[0]->url_with('/path#content' => { random => 24 })->to_string) };
get '/external' => sub { $_[0]->render(text => $_[0]->url_with('http://flodhest.net#content' => { random => 24 })->to_string) };
get '/some/named/route' => sub {};
get '/cap/:a' => sub {};

get '/link-with-text' => sub { $_[0]->render(text => $_[0]->link_with('Link text', '/path#content' => { age => 42 })) };
get '/link-with-sub' => sub { $_[0]->render(text => $_[0]->link_with('somenamedroute#form' => { name => 'Bob' }, sub { 'Sub text' })) };
get '/link-with-cap' => sub { $_[0]->render(text => $_[0]->link_with('capa#list' => { a => 42 }, { b => 24 }, sub { 'cap' })) };

$t->get_ok('/echo1?page=1')->content_is('/echo1?page=1');
$t->get_ok('/echo2?page=1')->content_is('/echo2?page=1');
$t->get_ok('/name?page=1')->content_is('/some/named/route?page=1&age=42#list');
$t->get_ok('/path?page=1')->content_is('/path?page=1&random=24#content');
$t->get_ok('/external?page=1')->content_is('http://flodhest.net?page=1&random=24#content');

$t->get_ok('/link-with-text?page=1')->content_is('<a href="/path?page=1&amp;age=42#content">Link text</a>');
$t->get_ok('/link-with-sub?page=1')->content_is('<a href="/some/named/route?page=1&amp;name=Bob#form">Sub text</a>');
$t->get_ok('/link-with-cap?page=1')->content_is('<a href="/cap/42?page=1&amp;b=24#list">cap</a>');
