#! /bin/bash
datasra="/home/rstudio/disk/data/sra_data"
geno="/home/rstudio/disk/genome"

# create dir
#mkdir /home/rstudio/disk/genome
cd /home/rstudio/disk/genome

#fasta sequences whole mouse transcriptome
#wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/gencode.vM23.pc_transcripts.fa.gz
#gunzip gencode.vM23.pc_transcripts.fa.gz > gencode.vM23.pc_transcripts.fa

#Dans le fasta, on garde le nom des transcrits et des gènes correpsondants
#tmp est le fichier à deux colonnes avec les correspondances transcrits - gènes
#awk 'BEGIN{FS="|"}{if($1~">"){print substr($1,2,length($1)),"\t",$6}}' gencode.vM23.pc_transcripts.fa > tmp.txt

#On recrée le fichier des transcrits de références avec le premier nom uniquement car alevin ne marche pas sinon
#awk 'BEGIN{FS="|"}{print $1}' gencode.vM23.pc_transcripts.fa > ref_transcripts

# salmon index 
#créer un dictionnaire de versions compréssées des mots de 31 lettres des transcrits de références 
#salmon index -t $geno"/ref_transcripts" -i transcripts_index -k 31

#alevin
#mapping and quantification

salmon alevin -l ISR \
-1 $datasra"/SRR8795649_1.fastq" \
-2 $datasra"/SRR8795649_2.fastq" \
--chromium  -i $geno"/transcripts_index" -p 6 -o $geno"/alevin_WT_output" --tgMap $geno"/tmp.txt"

salmon alevin -l ISR \
-1 $datasra"/SRR8795651_1.fastq" \
-2 $datasra"/SRR8795651_2.fastq" \
--chromium  -i $geno"/transcripts_index" -p 6 -o $geno"/alevin_APP/_output" --tgMap $geno"/tmp.txt"



#ancien alevin ou on avait poolé les deux conditions
#salmon alevin -l ISR \
#-1 $datasra"/SRR8795649_1.fastq" $datasra"/SRR8795651_1.fastq" \
#-2 $datasra"/SRR8795649_2.fastq" $datasra"/SRR8795651_2.fastq" \
#--chromium  -i $geno"/transcripts_index" -p 6 -o $geno"/alevin_output" --tgMap $geno"/tmp.txt"



# add spike ins ?
#wget https://assets.thermofisher.com/TFS-Assets/LSG/manuals/ERCC92.zip
#unzip ERCC92.zip
#cat 

#on utilisera pas l'annotaion finalement
# get annotation using Gencode
#wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/gencode.vM23.primary_assembly.annotation.gtf.gz
#gunzip -c gencode.vM23.primary_assembly.annotation.gtf.gz > gencode.vM23.primary_assembly.annotation.gtf

#on fait pas celui la parce qie dans le fasta il y a le nom des genes et des transcrits direct
#awk '{if($3=="transcript"){print substr($12,2,length($12)-3)}}' gencode.vM23.primary_assembly.annotation.gtf > tx2gene.txt

#awk '{...}' ERCC92.gtf > ercc.txt
#... > tx2geneercc.txt
