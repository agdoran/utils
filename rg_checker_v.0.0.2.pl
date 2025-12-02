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

my $mm = 0;
my $ml = 0;

my %colcount;
my %RGcount;
my %RGheadcount;
my %RGMM;
my %RGML;

my $totalrecords = 0;

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

	# track total count of records
	$totalrecords++;

	# track per line mm and ml - not a counter. 0 not present, 1 and MM+ML are present
	my $lineMM = 0;
	my $lineML = 0;
	my $currentRG = "";

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
			$currentRG = (split(/\:/, $cols[$i]))[2];

			# check to ensure row RG tag is not null 
			unless(defined $rowrg){
				$rowrg = "ISNULL";
				$currentRG = "ISNULL";
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

		# count the rows that have MM and ML tags (no check for defined value)
		if($cols[$i] =~ m/^MM/i){
			$mm++;
			$lineMM = 1;
		}
		if($cols[$i] =~ m/^ML/i){
			$ml++;
			$lineML = 1;
		}
	}

	# classify the presence of RG tags (1,0 or >1 RG tags in row)
	if($rowc == 1){
		$rg++;
	}elsif($rowc == 0){
		$norg++;
		
		# RG value is missing from row - different from a RG present with no value
		my $miss = "MISS";
		$RGheadcount{$miss} = 0;
		$RGcount{$miss}++;

		$currentRG = "MISS";

	}elsif($rowc > 1){
		$mulrg++;
		my $many = "MANY";
		$RGheadcount{$many} = 0;
		$RGcount{$many}++;

		$currentRG = "MANY";
	}


	# increment the count for MM and ML for the current read group
	if(exists $RGMM{$currentRG}){
		$RGMM{$currentRG}++ if($lineMM > 0);
	}else{
		if($lineMM > 0){
			$RGMM{$currentRG} = 1;
		}else{
			$RGMM{$currentRG} = 0;
		}
	}

	if(exists $RGML{$currentRG}){
		$RGML{$currentRG}++ if($lineML > 0);
	}else{
		if($lineML > 0){
			$RGML{$currentRG} = 1;
		}else{
			$RGML{$currentRG} = 0;
		}
	}
}

#print header
print "#Total-records\tOneRG-in-row\tNoRG-in-row\tManyRG-in-row\tRGdefined-in-header\tRGnotDefined-in-header\tRows-with-MM\tRows-with-ML\n";
# print metrics
print "$totalrecords\t$rg\t$norg\t$mulrg\t$isdef\t$notdef\t$mm\t$ml\n";

# print a count of the number rows with X number of columns
print "#RG_ID\tHeader-count\tCount-of-rows\tRecords-with-MM\tRecords-with-ML\n";
foreach my $key (keys %RGcount){

	print "##$key\t$RGheadcount{$key}\t$RGcount{$key}\t$RGMM{$key}\t$RGML{$key}\n";

}

$sdate = gmtime();
print STDERR "Finished: $sdate\n";
