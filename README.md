rg_checker.pl

To run, pipe from samtools view to this script. Please ensure samtools view also generates the header for additional checks.
Run as shown:

samtools view -h $BAM | perl rg_checker.pl 


This will generate two sections of output. All headers are prefixed with #. All output is to STDOUT.
Every 1 million lines a status will be printed to STDERR with a timestamp. 

The output columns in the first two lines are counts of the number of non-header rows with:
    i) a single RG tag,
    ii) no RG tag, 
    iii) >1 RG tag, 
    iv) an RG tag defined in the header 
    v) an RG tag not defined in the header

The headers for these are:
    OneRG-in-row
    NoRG-in-row
    ManyRG-in-row
    RGdefined-in-header
    RGnotDefined-in-header

In the second section of output, every row is prefixed with ## to easily extract later.
This section lists each RG value from the BAM in a new row. Each row has three columns:
    i) the RG value, 
    ii) the number of times this is present in the header (to identify duplicate entries)  
    iii) the numbef of times a read has this RG value

If an RG tag value is blank (NULL) in the records of the BAM, this will be called "ISNULL" in the output section of this script.
This will identify instances where the RG entry is incorrectly written in the BAM / SAM

