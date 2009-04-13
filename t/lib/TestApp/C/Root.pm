package TestApp::C::Root;

use strict;
use base qw/Catalyst::Controller/;
__PACKAGE__->config->{namespace} = '';

sub check :Local {
    my ( $self, $c ) = @_;
    $c->forward('V::TT');
}

sub no_cache :Local {
    my ( $self, $c ) = @_;
    $c->stash->{content} = 'no_cache';
    $c->stash->{template} = 'no_cache.tt';
    $c->forward('V::TT');
}

sub no_cache2 :Local {
    my ( $self, $c ) = @_;
    $c->stash->{content} = 'no_cache2';
    $c->stash->{template} = 'no_cache.tt';
    $c->forward('V::TT');
}

sub cache :Local {
    my ( $self, $c ) = @_;
    $c->stash->{content} = 'cache';
    $c->forward('V::TT');
}

sub cache2 :Local {
    my ( $self, $c ) = @_;
    $c->stash->{content} = 'cache2';
    $c->stash->{template} = 'cache.tt';
    $c->forward('V::TT');
}

sub cache3 :Local {
    my ( $self, $c ) = @_;

    sleep 2;

    $c->stash->{content} = 'cache3';
    $c->stash->{template} = 'cache.tt';
    $c->forward('V::TT');
}

sub busy :Local {
    my ( $self, $c ) = @_;
    $c->stash->{content} = 'busy';
    $c->forward('V::TT');
}

sub sort :Local {
    my ( $self, $c ) = @_;
    my @data = ('a','b','c');
    my $order = $c->stash->{order} = $c->req->param('order') || 'asc';
    @data = ($order eq 'asc') ? sort @data : reverse sort @data;
    $c->stash->{content} = "@data";
    $c->forward('V::TT');
}

1;
