package PDF::Writer::pdfapi2;

use strict;
use PDF::API2 0.40;

=head1 NAME

PDF::Writer::pdfapi2 - PDF::API2 backend

=head1 SYNOPSIS

(internal use only)

=head1 DESCRIPTION

No user-serviceable parts inside.

=cut

my %dispatch = (
    pdf => [qw( stringify info )],
    txt => [qw( font )],
    gfx => [qw( move line linewidth stroke fill )],
    ''  => [qw( parameter save_state restore_state end_page )],
);

sub new {
    my $class = shift;
    return bless({ pdf => PDF::API2->new }, $class);
}

sub open {
    my ($self, $f) = @_;
    $self->{filename} = $f;
    return (!-e $f or (!-d $f and -w $f));
}

sub save {
    my $self = shift; my $p = $self->{pdf};
    $p->saveas($self->{filename});
}

sub open_image {
    my $self = shift; my $p = $self->{pdf};
    my ($type, $file, $foo, $bar) = @_;

    require "PDF/API2/Resource/XObject/Image/\U$type\E.pm";
    return "PDF::API2::Resource::XObject::Image::\U$type\E"->new($p->{pdf}, $file);
}

sub image_width {
    my $self = shift; my $p = $self->{pdf};
    my ($image) = @_;
    return $image->width;
}

sub image_height {
    my $self = shift; my $p = $self->{pdf};
    my ($image) = @_;
    return $image->height;
}

sub place_image {
    my $self = shift; my $p = $self->{pdf};
    my ($image, $x, $y, $scale) = @_;
    #$y -= $image->height;
    $self->{gfx}->image($image, $x, $y, $scale);
}

sub close_image {
}

sub find_font {
    my $self = shift; my $p = $self->{pdf};
    my ($face, $pdf_encoding, $is_embed) = @_;
    my $mode = (
        ($face =~ /\.(?:pf[ab]|ps)$/i)
            ? 'ps' :
        ($face =~ /\.(?:ttf|otf|ttc)$/i)
            ? 'tt' :
        ($face =~ /(traditional|simplified|korean|japanese2?)/)
            ? 'cjk'
        : 'core'
    ) . 'font';

    # XXX - handle $pdf_encoding and $is_embed?
    return $p->can($mode)->($p, $face);
}

sub begin_page {
    my $self = shift; my $p = $self->{pdf};
    my ($width, $height) = @_;

    my $page = $p->page;
    $page->mediabox($width, $height);

    $self->{gfx} = $page->gfx;
    $self->{txt} = $page->text;
    $self->{page} = $page;

    return $page;
}

sub color {
    my $self = shift; my $p = $self->{pdf};
    my ($mode, $palette, @colors) = @_;

    die 'Palette other than "rgb" is not supported' unless $palette eq 'rgb';

    $self->{gfx}->fillcolor(@colors) unless $mode eq 'stroke';
    $self->{gfx}->strokecolor(@colors) unless $mode eq 'fill';
    $self->{txt}->fillcolor(@colors) unless $mode eq 'stroke';
    $self->{txt}->strokecolor(@colors) unless $mode eq 'fill';
}

sub show_boxed {
    my $self = shift; my $p = $self->{pdf};
    my ($str, $x, $y, $w, $h, $j, $m) = @_;

    return 0 if $m eq 'blind';

    my $method = 'text';
    if ($j eq 'right') {
        $x += $w;
        $method .= "_$j";
    }
    elsif ($j eq 'center') {
        $x += $w / 2;
        $method .= "_$j";
    }

    $self->{txt}->translate($x, $y);

    my @tokens = split(/ /, $str);
    my @try;
    while (@tokens) {
        push @try, shift(@tokens);
        if ($self->{txt}->advancewidth("@try") >= $w) {
            # overflow only if absolutely neccessary
            pop @try if @try > 1;
            $self->{txt}->can($method)->($self->{txt}, "@try");
            return length($str) - length("@try");
        }
    }

    $self->{txt}->can($method)->($self->{txt}, $str);

    return 0;
}

sub show_xy {
    my $self = shift; my $p = $self->{pdf};
    my ($str, $x, $y) = @_;

    $self->{txt}->translate($x, $y);
    $self->{txt}->text($str);
}

sub font_size {
    my $self = shift; my $p = $self->{pdf};
    return $self->{txt}{' fontsize'};
}

sub rect {
    my $self = shift; my $p = $self->{pdf};
    my $gfx = $self->{gfx};
    $gfx->linewidth(0.2);
    $gfx->rect(@_);
}

sub close { %{$_[0]} = (); }

while (my ($k, $v) = each %dispatch) {
    foreach my $method (@$v) {
        no strict 'refs';
        if ($k) {
            *$method = sub {
                my $self = shift;
                $self->{$k}->can($method)->($self->{$k}, @_);
            };
        }
        else {
            *$method = sub {
                return 1;
            }
        }
    }
}

1;

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2004 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
