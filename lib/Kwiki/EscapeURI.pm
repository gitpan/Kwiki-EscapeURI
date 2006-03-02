package Kwiki::EscapeURI;
use strict;
use warnings;
use Kwiki::Plugin -Base;
use mixin 'Kwiki::Installer';

use URI::Escape qw(uri_escape_utf8);

our $VERSION = '0.01';

const class_id => 'escape_uri';
const class_title => "uri escape to raw UTF8 links";

sub init {
    super;
    $self->hub->template->add_path('plugin/escape_uri/template/tt2');
    my $formatter = $self->hub->load_class('formatter');
    $formatter->table->{forced} = 'Kwiki::EscapeURI::ForcedLink';
}

sub register {
    my $registry = shift;
    $registry->add(preload => 'escape_uri');
    $registry->add(hook => 'page:kwiki_link', pre => 'uri_hook');
}

sub uri_hook {
    my $hook = pop;
    $hook->code(undef);
    my ($label) = @_;
    my $page_uri = $self->uri;
    $page_uri =~ s/([^\x20-\x7e]+)/uri_escape_utf8($1)/eg;
    $label = $self->title
      unless defined $label;
    my $class = $self->active
      ? '' : ' class="empty"';
    qq(<a href="?$page_uri"$class>$label</a>);
}

package Kwiki::EscapeURI::ForcedLink;
use base 'Kwiki::Formatter::ForcedLink';

use URI::Escape qw(uri_escape_utf8);

sub html {
    $self->matched =~ $self->pattern_start;
    my $target = $1;
    my $page_uri = $target;
    $page_uri =~ s/([^\x20-\x7e]+)/uri_escape_utf8($1)/eg;
    my $text = $self->escape_html($target);
    my $class = $self->hub->pages->new_from_name($target)->exists
      ? '' : ' class="empty"';
    return qq(<a href="?$page_uri"$class>$target</a>);
}

package Kwiki::EscapeURI;
__DATA__

=head1 NAME 

Kwiki::EscapeURI - uri escape to raw UTF8 links

=head1 SYNOPSIS

 $ cd /path/to/kwiki
 $ kwiki -add Kwiki::EscapeURI

=head1 DESCRIPTION

Changes the internal links that Kwiki create. Instead of
raw UTF8 links, it will just be uri escaped.

=head1 AUTHOR

Kzuhiro Osawa

=head1 SEE ALSO

L<URI::Escape>

=head1 COPYRIGHT

Copyright (c) 2006. Kazuhiro Osawa All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO


=cut
__plugin/escape_uri/template/tt2/home_button.html__
<a href="?[% main_page %]" accesskey="h" title="Home Page">
[% INCLUDE home_button_icon.html %]
</a>
