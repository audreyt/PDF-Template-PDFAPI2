use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use File::Spec;

warn << '.';
### PLEASE NOTE ##############################################

This distribution is a development-in-progress fork by
Autrijus Tang, with full intentions to remerge to the main
PDF::Template tree at some point.

The official maintainer of PDF::Template is Rob Kinyon.

##############################################################
.

my $prereqs = {
    'Test::Simple'   => 0.44,
    'XML::Parser'    => 0.01,
    'IO::File'       => 0.01,
    'File::Basename' => 0.01,
    'PDF::API2'      => 0.40,
};

# The assumption is the 5.8.0 and greater doesn't need Unicode::String.
if ($] < 5.008)
{
    print "Do you want Unicode support? ";
    my $answer = <STDIN>;
    my $need_unicode = $answer =~ /^[Yy]/;

    my $use_unicode = 0;
    if ($need_unicode)
    {
            $prereqs{'Unicode::String'} = '0.01';
            $use_unicode = 1;
    }
}

use_unicode($use_unicode);

WriteMakefile(
    DISTNAME     => 'PDF-Template-PDFAPI2',
    NAME         => 'PDF::Template',
    VERSION      => '0.40_01',
    AUTHOR       => 'Autrijus Tang <autrijus@autrijus.org>',
    ABSTRACT     => 'PDF::Template',
    PREREQ_PM    => $prereqs,
);

sub use_unicode
{
    my $using_unicode = shift;

    my @filenames = map {
        File::Spec->catfile(
            qw( lib PDF Template ),
            @{$_},
        )
    } ( [ qw( Element TextBox.pm ) ], [ qw( TextObject.pm ) ] );

    foreach my $filename (@filenames)
    {
        open(IN_FILE, $filename)
            or die "Cannot open '$filename' for reading: $!\n";
        my @lines = <IN_FILE>;
        close(IN_FILE);

        if ($using_unicode)
        {
            for (@lines)
            {
                s/^UNI_YES / /;
                s/^UNI_NO  /#/;
            }
        }
        else
        {
            for (@lines)
            {
                s/^UNI_YES /#/;
                s/^UNI_NO  / /;
            }
        }

        open(OUT_FILE, ">$filename")
            or die "Cannot open '$filename' for writing: $!\n";
        print OUT_FILE @lines;
        close(OUT_FILE);
    }

    return 1;
}
