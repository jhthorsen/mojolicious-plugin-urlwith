use inc::Module::Install;

name q(Mojolicious-Plugin-UrlWith);
all_from q(lib/Mojolicious/Plugin/UrlWith.pm);

requires q(Mojolicious) => 3.30;

test_requires q(Test::More) => 0.90;

bugtracker q(http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-UrlWith);
homepage q(http://search.cpan.org/dist/Mojolicious-Plugin-UrlWith);
repository q(git://github.com/jhthorsen/mojolicious-plugin-urlwith);

# install_script glob('bin/*');
auto_install;
WriteAll;
