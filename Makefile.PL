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
};

$prereqs{'PDF::API2'} = 0.40 unless eval { require pdflib_pl; 1 };

# The assumption is the 5.8.0 and greater doesn't need Unicode::String.
if ($] < 5.008)
{
    print "Do you want Unicode support? ";
    $prereqs{'Encode::compat'} = '0.01' if <STDIN> =~ /^[Yy]/;
}

WriteMakefile(
    DISTNAME     => 'PDF-Template-PDFAPI2',
    NAME         => 'PDF::Template',
    VERSION      => '0.40_07',
    AUTHOR       => 'Autrijus Tang <autrijus@autrijus.org>',
    ABSTRACT     => 'PDF::Template',
    PREREQ_PM    => $prereqs,
);
