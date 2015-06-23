use strict;
use warnings;

use Test::More tests => 3;
use ExtUtils::Manifest qw( maniskip );

# ABSTRACT: Ensure include-default is memory only

use lib 't/tlib';
use Test::TempDir::Tiny qw( in_tempdir );

sub _spew {
    my ( $filename, $content ) = @_;
    open my $fh, '>', $filename or die "Can't open $filename for writing. $!";
    print {$fh} $content or die "Error writing to $filename. $!";
    close $fh or die "Error closing $filename. $!";
}

sub _slurp {
    my ($filename) = @_;
    my $content;
    open my $fh, '<', $filename or die "Can't open $filename for reading. $!";
    local $/ = undef;
    $content = <$fh>;
    close $fh or warn "Error closing $filename. $!";
    return $content;
}

in_tempdir 'no-default-expansions' => sub {

    _spew( 'MANIFEST.SKIP', qq[#!include_default] );

    my $skipchk = maniskip();

    my $skipcontents = _slurp('MANIFEST.SKIP');

    unlike( $skipcontents, qr/#!start\s*included/, 'include_default not expanded on disk' );

    ok( $skipchk->('Makefile'),     'Makefile still skipped by default' );
    ok( !$skipchk->('Makefile.PL'), 'Makefile.PL still not skipped by default' );
};
done_testing;
