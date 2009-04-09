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
            'non_cached_include.tt' => 0, # dont cache
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

=== env check
--- input filter
/check
--- expected
ok

=== no cache
--- input filter
/no_cache
--- expected chomp
no_cache

=== no cache2
--- input filter
/no_cache2
--- expected chomp
no_cache2

=== set cache
--- input filter
/cache
--- expected chomp
cache

=== get cache
--- input filter
/cache2
--- expected chomp
cache

=== cache expired
--- input filter
/cache3
--- expected chomp
cache3
