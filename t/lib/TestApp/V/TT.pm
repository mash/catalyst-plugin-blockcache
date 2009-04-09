package TestApp::V::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tt', PRE_PROCESS => 'macro.tt', EVAL_PERL => 1, );

1;
