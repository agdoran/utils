## 1. rg_checker
### Check the read group info of a BAM / SAM for inconsistency 
using ```rg_checker.pl```

#### Running this script
To run, pipe from samtools view to this script. Please ensure samtools view also generates the header for additional checks.
Run as shown:

```
samtools view -h $BAM | perl rg_checker.pl 
```

This will generate two sections of output.
All headers are prefixed with #.
All output is to STDOUT.

Every 1 million lines a status will be printed to STDERR with a timestamp.
This will be printed to your terminal screen. 

#### Output generated
All output is to STDOUT (and can be redirected with > or | ). 

```
samtools view -h $BAM | perl rg_checker.pl > my_bam_rg_checks.txt 
```

##### Section 1 - summary of RG status
The output columns in the first two lines are counts of the number of non-header rows with:
1. a single RG tag,
2. no RG tag, 
3. \>1 RG tag, 
4. an RG tag defined in the header, 
5. an RG tag not defined in the header


The headers for these are:
1. OneRG-in-row
2. NoRG-in-row
3. ManyRG-in-row
4. RGdefined-in-header
5. RGnotDefined-in-header

##### Section 2 - Occurance of each RG tag in header and records
In the second section of output, every row is prefixed with ## to easily extract later.
This section lists each RG value from the BAM in a new row. Each row has three columns:
1. the RG  
2. the number of times this is present in the header (to identify duplicate entries)  
3. the numbef of times a read has this RG value

If an RG tag value is blank (NULL) in the records of the BAM, this will be called "ISNULL" in the output section of this script.
This will identify instances where the RG entry is incorrectly written in the BAM / SAM


###### Disclaimer
Scripts here comes with no assurances of usefulness, utility or accuracy and should be tested before use.
The author of this script has no responsibility to the performance of this script.
The script can be downloaded, modified and redistributed as anyone sees fit. 
