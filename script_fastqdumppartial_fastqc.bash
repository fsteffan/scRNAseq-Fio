#! /bin/bash


# Again go create / go in the working directory
# Create a folder for the fastqc
mkdir /home/rstudio/disk/data/fastqc


#For each fastqc
#On test la quelaité des fichiers qui nous intéressent (Barcode+UMI (_1) et Transcrits (_2))

cd /home/rstudio/disk/data/sra_data
SRR="SRR8795649 SRR8795651"
for x in $SRR
do
fastqc  $x"_1.fastq" -o /home/rstudio/disk/data/fastqc
fastqc  $x"_2.fastq" -o /home/rstudio/disk/data/fastqc
done

# Then collective analysis of all fastqc results

cd /home/rstudio/disk/data/fastqc
multiqc ./*_2*.zip &
