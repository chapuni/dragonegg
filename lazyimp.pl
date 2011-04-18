#!/usr/bin/perl

use File::Temp;

$outs = shift(@ARGV);

$dir = File::Temp::tempdir(CLEANUP => 1);
print "$dir\n";
push(@imps, &emit_00);
push(@imps, &emit_zz);
while (<>) {
    if (/^\s*(\w+)\s+@(\d+)\s+DATA/) {
	push(@imps, &emit_imp_imp($dir, $1, $2));
    } elsif (/^\s*(\w+)\s+@(\d+)/) {
	push(@imps, &emit_imp($dir, $1, $2));
    }
}

unlink($outs);
system("ar rcsv $outs @imps");

exit;

sub emit_00
{
    my $o = sprintf("%s/00.o", $dir, $xo, $sym);

    my $h;
    open($h, "| as -o $o") || die;
    print $h <<EOS;
.section .bss\$lazy_00
.globl __AS
__AS:
.section .rdata\$lazy_00
.globl __SS
__SS:
EOS
;

    close($h);

    return $o
}

sub emit_zz
{
    my $o = sprintf("%s/zz.o", $dir, $xo, $sym);

    my $h;
    open($h, "| as -o $o") || die;
    print $h <<EOS;
.section .bss\$lazy_zz
.globl __AE
__AE:
.section .rdata\$lazy_zz
.globl __SE
__SE:
EOS
;

    close($h);

    return $o
}

sub emit_imp
{
    my ($dir, $sym, $ord) = @_;
    my $xo = sprintf("%08X", $ord);
    my $o = sprintf("%s/i%s.o", $dir, $xo);

    print STDERR "Emitting $o - $sym\n";

    my $h;
    open($h, "| as -o $o") || die;
    print $h <<EOS;
.text
.globl _$sym
_$sym: jmp *__imp__$sym
.section .bss\$lazy_i$sym
__imp__$sym:	.skip 4
.section .rdata\$lazy_i$sym
    .asciz "$sym"
EOS
;

    close($h);

    return $o
}

sub emit_imp_imp
{
    my ($dir, $sym, $ord) = @_;
    my $xo = sprintf("%08X", $ord);
    my $o = sprintf("%s/d%s.o", $dir, $xo);

    print STDERR "Emitting $o - $sym (DATA)\n";

    my $h;
    open($h, "| as -o $o") || die;
    print $h <<EOS;
.section .bss\$lazy_d$sym
.globl __imp__$sym
__imp__$sym:.skip 4
.section .rdata\$lazy_d$sym
    .asciz "$sym"
EOS
;

    close($h);

    return $o
}
