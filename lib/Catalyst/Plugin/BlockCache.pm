package Catalyst::Plugin::BlockCache;

use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
use NEXT;

our $VERSION = '0.01';


sub setup {
    my $c = shift;
    $c->NEXT::setup(@_);
    die __PACKAGE__ . " requires Catalyst::Plugin::Cache plugin" unless $c->can('cache');
    $c;
}

sub get_cached_block {
    my ($c, $key) = @_;

    $c->log->debug("[get_cached_block]key: $key");

    return;#$content;
}

sub set_cached_block {
    my ($c, $key, $content) = @_;

    $c->log->debug("[set_cached_block]key: $key\ncontent: \n$content");

    return $content;
}

1;
__END__

=head1 NAME

Catalyst::Plugin::BlockCache -

=head1 SYNOPSIS

  use Catalyst::Plugin::BlockCache;

=head1 DESCRIPTION

Catalyst::Plugin::BlockCache is

=head1 AUTHOR

Masakazu Ohtsuka E<lt>o.masakazu@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
