package Catalyst::Plugin::BlockCache;

use strict;
use warnings;
use base qw/Class::Data::Inheritable/;
use NEXT;

our $VERSION = '0.01';

__PACKAGE__->mk_classdata('_block_cache_namespace');
__PACKAGE__->mk_classdata('_block_cache_targets_config');
__PACKAGE__->mk_classdata('_block_cache_busy_lock');

sub setup {
    my $c = shift;
    $c->NEXT::setup(@_);
    die __PACKAGE__ . " requires Catalyst::Plugin::Cache plugin" unless $c->can('cache');
    $c->_block_cache_namespace( $c->config->{'Plugin::BlockCache'}{namespace} || 'BlockCache' );
    $c->_block_cache_targets_config( $c->config->{'Plugin::BlockCache'}{targets} || {} );
    $c->_block_cache_busy_lock( $c->config->{'Plugin::BlockCache'}{busy_lock} || 0 );

    $c;
}

sub get_cached_block {
    my ($c, $key) = @_;

    return $c->_get_block_cache( $key ) if $c->_block_cache_expire_time($key);
    return;
}

sub set_cached_block {
    my ($c, $key, $content) = @_;

    my $expire_time = $c->_block_cache_expire_time($key);
    $c->_set_block_cache( $key, $content, $expire_time ) if $expire_time;

    return $content;
}

sub _get_block_cache {
    my ($c, $key) = @_;
    
    my $ret = $c->cache->get( $c->_block_cache_key($key) );
    if ( $ret && $ret->{t} && $ret->{t} < time() ) {
        # expired
        if ( my $busy_lock = $c->_block_cache_busy_lock ) {
            $c->_set_block_cache( $key, $ret, $busy_lock );

            $c->log->debug("[" . __PACKAGE__ . "]$key has expired, but left in cache for $busy_lock seconds") if $c->config->{'Plugin::BlockCache'}{debug};
        }
        return; # and go get new content to set cache again
    }

    $c->log->debug("[" . __PACKAGE__ . "]got key: $key") if $ret && $ret->{c} && $c->config->{'Plugin::BlockCache'}{debug};

    return $ret->{c};
}

sub _set_block_cache {
    my ($c, $key, $value, $expire_time) = @_;

    $c->cache->set( $c->_block_cache_key($key), { c => $value, t => time() + $expire_time }, $expire_time + $c->_block_cache_busy_lock );

    $c->log->debug("[" . __PACKAGE__ . "]set key: $key for expire_time: $expire_time") if $expire_time && $c->config->{'Plugin::BlockCache'}{debug};
}

sub _block_cache_key {
    my ($c, $key) = @_;
    return $c->_block_cache_namespace . ":$key";
}

sub _block_cache_expire_time {
    my ($c, $key) = @_;
    my $expires = $c->_block_cache_targets_config->{$key};
    return $expires;
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
