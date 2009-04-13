use Test::Base qw/no_plan/;
use FindBin;
use lib "$FindBin::Bin/lib";
use File::Path;

# remove previous cache
rmtree 't/var' if -d 't/var';

use Catalyst::Test 'TestApp';
TestApp->config(
    cache => {
        storage => 't/var',
    },
    'Plugin::BlockCache' => {
        targets  => {
            'cached_include.tt'     => 1, # cache for 1sec
        },
    },
);
TestApp->setup( qw/Cache::FileCache BlockCache/ );

run_is input => 'expected';

sub filter {
    my $url = $_;
    my $content = get($url);
    return $content;
}

__END__

=== no params
--- input filter
/sort
--- expected chomp
a b c

=== params1
--- input filter
/sort?order=asc
--- expected chomp
a b c

=== params2
--- input filter
/sort?order=desc
--- expected chomp
c b a

=== params1 again
--- input filter
/sort?order=asc
--- expected chomp
a b c
