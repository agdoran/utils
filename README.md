## 1. rg_checker
### Check the read group info of a BAM / SAM for inconsistency 
using ```rg_checker_v0.0.2.pl```

#### Running this script
To run, pipe from samtools view to this script. Please ensure samtools view also generates the header for additional checks.
Run as shown:

```
samtools view -h $BAM | perl rg_checker_v0.0.2.pl 
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

##### Output section 1 - summary of RG status
The output columns in the first two lines are counts of the number of non-header rows with:
1. a single RG tag,
2. no RG tag, 
3. \>1 RG tag, 
4. an RG tag defined in the header, 
5. an RG tag not defined in the header
6. a tag for MM (the value of this is not assessed)
7. a tag for ML (the value of this is not assessed)


The headers for these are:
1. OneRG-in-row
2. NoRG-in-row
3. ManyRG-in-row
4. RGdefined-in-header
5. RGnotDefined-in-header
6. Rows-with-MM
7. Rows-with-ML

##### Output section 2 - Occurance of each RG tag in header and records
In the second section of output, every row is prefixed with ## to easily extract later.
This section lists each RG value from the BAM in a new row. Each row has five columns:
1. the RG  
2. the number of times this is present in the header (to identify duplicate entries)  
3. the number of times a read has this RG value
4. the number of records for this RG that has a MM tag (the value of this is not assessed, only the presence of a MM tag)
5. the number of records for this RG that has a ML tag (the value of this is not assessed, only the presence of a ML tag) 

##### Output section 2 - special conditions
If an RG tag value is blank (NULL) in the records of the BAM, this will be called "ISNULL" in the output section of this script.
This will identify instances where the RG tag is in the record but the value for this is a blank - entry is incorrectly written in the BAM / SAM.

Records where no RG is present in the BAM row at all will be included in the output but will have an RG value of MISS
Records where \>1 RG is present in the BAM row will be included in the output but will have an RG value of MANY 


##### Example output (with deliberately generated error modes reported with counts)
```
#Total-records  OneRG-in-row    NoRG-in-row     ManyRG-in-row   RGdefined-in-header     RGnotDefined-in-header  Rows-with-MM    Rows-with-ML
16265142        16265142        0       0       16265142        0       16265142        16265142
#RG_ID  Header-count    Count-of-rows   Records-with-MM Records-with-ML
##11d77535b149da7c6f7153939924a9fe29559cc7_dna_r10.4.1_e8.2_400bps_sup@v5.0.0   1       7918900 7918900 7918900
##de8117b1abf27d6d4ac91526772636b9a5ca7fde_dna_r10.4.1_e8.2_400bps_sup@v5.0.0   1       8346242 8346242 8346242
##ISNULL        0       1       0       0
##MISS  0       3       3       2
##MANY  0       2       1       0
```

###### Disclaimer
Scripts here comes with no assurances of usefulness, utility or accuracy and should be tested before use.
The author of this script has no responsibility to the performance of this script.
The script can be downloaded, modified and redistributed as anyone sees fit. 
