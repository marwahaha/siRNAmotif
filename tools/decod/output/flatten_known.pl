#!/usr/bin/env perl
use strict; use warnings;
use v5.10;
####
# Flatten -- print motif, score, background, etc as one line per positive match
#
# perl flatten.pl {6,7,8,9}/300ntVsG1000_{29,35}.txt > flattened.txt
####
my $negSet=29;
my $width=6;
my $positive=0;
my $motifNum=0;
my $motif='';
my $score=0;
my %letter=(0 =>'A', 1 =>'C', 2 =>'G',3 =>'T');

while(<>){
    chomp;
    given($_){
	when(/^#Motif width = (\d+)$/) { $width=$1 }
	when(m{^#Negative sequence file = ../../fas/masked/randomInGene_1000-.*-(\d+).fa.masked$}) { $negSet=$1 }
	when(m/^#Score = (\d+.?\d+)/){$score=$1 }
	when(m/^>Motif(\d+)/){
	    $motif='';
	    $motifNum=$1;
	    my @motifarray;
	    #read in motif (4 more lines) and build array
	    for (0..3) {
		$_=<>;
		my $idx=0;
		while(m/(\d+.?\d+)/g){
		    #@motif =( [ 0.00  0.000 1.000 ..]  #A
		    #          [ 0.00  0.000 1.000 ..]  #C
		    #          ....
		    #
		    #               idx
		    #      0     1    2    4  5  6
		    #
		    #A    0.0   1.0
		    #C    0.5   0.0
		    #G    0.5   0.0
		    #T    0.0   0.0 
		    #
		    #$motif[0][1]=1

		    push @{$motifarray[$idx]}, $&;
		    $idx++;
		}
	    }
	    
	    #motif is collected, now flatten to $motif
	    for my $pos (0..$#motifarray){
		for my $nt (0..3) {

		    my $freq = sprintf ( "%2.0f", $motifarray[$pos]->[$nt]*100);

		    if($freq > 0){
			$motif.= $freq if $freq<100; 
			$motif.= $letter{$nt} 
		    }
		}
		$motif.="|" unless $pos==$#motifarray;
	    }
	}
	when(m/^#Motif instances in positive sequences: $/){ $positive=1}
	when(m/^$/){ $positive=0}
	default{
	    #>MAL13P1.212-|revcom    457     ACATGC  7.2105
	    m/^>(.*)([+-])(\|revcom)?\t(\d+)\t([ATGCatgcN]+)\t(\d+.?\d+)$/;
	    next if !$&;
	    my $strand=$2;
	    my $gene=$1;
	    my $rc=$3?$3:"";
	    my $pos=$4;
	    my $seq=$5;
	    my $sscore=$6;
	    print join("\t",$width, $negSet,$motifNum, $score, $sscore, $motif, 
		    $seq, $pos,
	            $strand, $gene. $rc),"\n" if($positive);
	    
	}

    }
}


