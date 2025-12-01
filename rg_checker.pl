#!/usr/bin/perl -w
use strict;

# print start of script time
my $sdate = gmtime();
print STDERR "Starting:\t$sdate\n";

my $rg = 0;
my $norg = 0;
my $mulrg = 0;
my $notdef = 0;
my $isdef = 0;

my %colcount;
my %RGcount;
my %RGheadcount;

# this will read from standard in (the BAM must be piped to this script)
while(my $line = <>){
	chomp $line;

	# print processed lines status to STDERR every 1 million rows
	if($. % 1000000 == 0){
		my $date = gmtime();
		print STDERR "All lines to $. processed\t$date\n";
		
	}

	# parse RG rows in header
	if($line =~ m/^\@RG/){
		my $RGid = (split("\t", $line))[1];
		$RGid =~ s/ID\://;
		$RGcount{$RGid} = 0; # initialise RG hash - could add extra check to see if defined >1 times in header
		$RGheadcount{$RGid}++;
	}

	# skip header after parsing RG rows
	next if($line =~ m/^\@/);

	my @cols = split("\t", $line);
	$colcount{@cols}++; # count number of columns in row

	# set the row RG counter to zero, should always be reset on each row
	# this is used to check the presence of RG tag on each row
	my $rowc = 0;
	for(my $i = 11; $i < @cols; $i++){
		if($cols[$i] =~ m/^RG/i){
			$rowc++;

			# count/increment the number of occurrances of the read RG 
			my $rowrg = (split(/\:/, $cols[$i]))[2];

			# check to ensure row RG tag is not null 
			unless(defined $rowrg){
				$rowrg = "ISNULL";
			}

			# check if the read RG is already defined (should be in the header)
			if(exists $RGcount{$rowrg}){
				$isdef++;
			}else{
				$notdef++;
				$RGheadcount{$rowrg} = 0;
			}

			$RGcount{$rowrg}++;

		}
	}

	# classify the presence of RG tags (1,0 or >1 RG tags in row)
	if($rowc == 1){
		$rg++;
	}elsif($rowc == 0){
		$norg++;
	}elsif($rowc > 1){
		$mulrg++;
	}	
}

#print header
print "#OneRG-in-row\tNoRG-in-row\tManyRG-in-row\tRGdefined-in-header\tRGnotDefined-in-header\n";
# print metrics
print "$rg\t$norg\t$mulrg\t$isdef\t$notdef\n";

# print a count of the number rows with X number of columns
print "#RD_ID\tHeader-count\tCount-of-rows\n";
foreach my $key (keys %RGcount){

	print "##$key\t$RGheadcount{$key}\t$RGcount{$key}\n";

}

$sdate = gmtime();
print STDERR "Finished: $sdate\n";
