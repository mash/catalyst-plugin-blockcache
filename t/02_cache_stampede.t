use Test::More qw/no_plan/;
use FindBin;
use lib "$FindBin::Bin/lib";
use File::Path;
use Time::HiRes qw(time sleep);

# thanks for the test to C::P::PageCache

# remove previous cache
rmtree 't/var' if -d 't/var';

use Catalyst::Test 'TestApp';
TestApp->config(
    cache => {
        storage => 't/var',
    },
    'Plugin::BlockCache' => {
        targets  => {
            'sleep_1sec.tt' => 1,
        },
        busy_lock => 2,
    },
);
TestApp->setup( qw/Cache::FileCache BlockCache/ );

# Request a slow page once, to cache it
ok( my $res = request('/busy'), 'request ok' );

# Wait for it to expire
sleep 2;

# Fork, parent requests slow page.  After parent requests, child
# requests, and gets cached page while parent is rebuilding cache
if ( my $pid = fork ) {
    # parent
    my $start = time();
    
    ok( $res = request('/busy'), 'parent request ok' );
    cmp_ok( time() - $start, '>=', 1, 'slow parent response ok' );
    
    # Get status from child, since it can't print 'ok' messages without
    # confusing Test::More
    wait;

    is( $? >> 8, 0, 'fast child response ok' ); # $? returns 256 when "exit 1;" in child
}
else {
    # child
    sleep 0.1;
    my $start = time();

    request('/busy');

    if ( time() - $start < 1 ) {
        exit 0; # busy_lock works, child process, which started to request after his parent, ends under 1sec = got response from cache
    }
    else {
        exit 1; # took time = cached didnt work = cache stampede happened ><
    }
}
