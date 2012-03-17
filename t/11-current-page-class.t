use warnings;
use strict;
use lib qw(lib);
use Test::More;
use Test::Mojo;
use Mojolicious::Lite;

my $t = Test::Mojo->new;

plan tests => 6;
plugin url_with => { current_page_class => 'current-page' };

get '/link-with-class' => sub { $_[0]->render(text => $_[0]->link_with(linkwithclass => { a => 42 }, { b => 24 }, sub { 'i got class' })) };
get '/link-without-class' => sub { $_[0]->render(text => $_[0]->link_with(linkwithclass => { a => 42 }, { b => 24 }, sub { 'i got class' })) };

$t->get_ok('/link-without-class?foo=1')
    ->content_like(qr{href="/link-with-class\?foo=1&amp;b=24"}, '...with href')
    ->content_unlike(qr{class="current-page"}, '...without class')
    ;

$t->get_ok('/link-with-class?foo=1')
    ->content_like(qr{href="/link-with-class\?foo=1&amp;b=24"}, '...with href')
    ->content_like(qr{class="current-page"}, '...with class')
    ;
