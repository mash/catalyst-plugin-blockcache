use inc::Module::Install;
name 'Catalyst-Plugin-BlockCache';
#all_from 'lib/.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
