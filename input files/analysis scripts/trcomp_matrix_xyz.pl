#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  tr_matrix_xyz.pl
#
#        USAGE:  ./tr_matrix_xyz.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Beisi Xu (Postdoc), xubeisi [at] gmail DOT com
#      COMPANY:  UTHSC
#      VERSION:  1.0
#      CREATED:  09/13/2010 06:31:47 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

my @tt;
my $nl=0;
my $nx=-1;
my $nn=0;

while(my $line=<>){
	chomp($line);
	@tt=();
	@tt=split(' ',$line);
	$nx++;
	if($nx==0){$nl=scalar(@tt);}
	if(!exists($tt[1])){last;}
	if(exists($tt[1]) && $nl!=scalar(@tt))
	{
		die "Not matrix at line $nx\n";
	}
	for(my $ny=0;$ny<$nl;$ny++)
	{
	 printf("%d\t%d\t%lf\n",$nx+1,$ny+1,$tt[$ny]);
	}
	last if eof;
}

