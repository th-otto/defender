#!/usr/bin/perl -w
# 
# genmagic -- dump magics from (crosscompiled...) asm_gd.o object
# file
use Fcntl qw( SEEK_SET SEEK_CUR O_RDONLY );

$f = 'asm_gd.o';
$f = $ARGV[0] if $#ARGV >= 0;

$firstsym = 'idata_features';
$val = 'Z28N';
#       const char name[28];
#       long value;                                                            

sysopen(M, $f, O_RDONLY) || die "open failed";
binmode(M,':raw');
$offset = 0;
while (sysread(M, $d, length(pack( $val, 0)))) {
    ($name, $valx) = unpack( $val, $d );
    last if ( $name =~ /^$firstsym$/s );
    $offset = ++$offset;
    sysseek(M, $offset, SEEK_SET) || die "can't seek";
}

$name =~ /^$firstsym$/s || die "symbols not found";
sysseek(M, $offset, 0) || die "can't seek";
while (sysread(M, $d, length(pack( $val, 0)))) {
    ($name, $valx) = unpack( $val, $d);
    last if !$name;
    print "\t.equ\t$name, $valx\n";
}
close M || die "Can't close";
