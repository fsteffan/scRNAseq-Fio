# NGS_Practicals_scRNA

05/11/2019
On s'est donnée la permission de modifier le disk
#sudo chown :rstudio:rstudio disk

On a cloné le dépôt avec les squelettes de script 
#git clone ADRESSE

On a crée le git sur github
Pour enregistrer un nouveau git il faut : 
#git add FICHIER
#git commit -m "comm"
#git push 

On a modifié le fichier script_fastqdump.bash afin de télecharger quelques données de l'article 
--> 16 months WT whole brain (SRR8795649) and 16 months APP/PS1 whole brain (SRR8795651)
- fastqdump va chercher dans NCBI GEO
- -X 100000 : telecharge les 1000000 premiers reads de chaque condition
- --split-files : sépare les trois reads (read du barcode, read séquence, read du pool(pool plsr conditions et etiquette les cDNA pour savoir à quelles conditions ils appartiennent))

06/11/2019
On test la qualité des fichiers qui nous intéressent (Barcode+UMI (_1) et Transcrits (_2))
(script_fastqdumppartial)
#fastqc pour chaque fichiers _1.fastqc et _2.fastqc
#multiqc ./*_2*.zip & 
--> on compare les qualités des transcrits des deux conditions
   --> Les qualités sont bonnes, il y a beaucoup de duplications mais ce n'est pas grave car avec le scRNAseq, c'est logique d'avoir des duplications (même UMI dupliqué en PCR ou même transcrit captés par des UMI différents (sélection par la queue polyA donc pas de diversité à l'intérieur des transcrits))
   
On a téléchargé les transcrits de référence du génome de souris
(script_prepmap)
#wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M23/gencode.vM23.pc_transcripts.fa.gz 
(accéder au site internet et au fichier en particulier)
#gunzip gencode.vM23.pc_transcripts.fa.gz > gencode.vM23.pc_transcripts.fa 
(dezipper le fichier)

On a changé le format de ce fichier car il a pleins de noms en prmière ligne et pas seulement celui du transcrits
#awk 'BEGIN{FS="|"}{print $1}' gencode.vM23.pc_transcripts.fa > ref_transcripts

On cherche sur le site d'alevin de quelles entrées il a besoin; il manque un tableau avec en correspondance le nom des transcrits et des gènes correspondants (gène en général, pas les épissages)
#awk 'BEGIN{FS="|"}{if($1~">"){print substr($1,2,length($1)),"\t",$6}}' gencode.vM23.pc_transcripts.fa > tmp.txt

On crée l'index, un dictionnaire de versions compréssées des mots de 31 lettres des transcrits de références du génome de souris
#salmon index -t $geno"/ref_transcripts" -i transcripts_index -k 31

Pour le mapping et la quantification de scRNAseq, on utilise alevin
#salmon alevin -l ISR \
#-1 $datasra"/SRR8795649_1.fastq" $datasra"/SRR879651_1" \
#-2 $datasra"/SRR8795649_2.fastq" $datasra"/SRR879651_2" \
#--chromium  -i $geno"/transcripts_index" -p 6 -o $geno"/alevin_output" --tgMap $geno"/tmp.txt"
-l : library type = ISR pour 10X d'après les recommandations du site
-1 : CB + UMI fastq sequences
-2 : read sequence fastq
--protocol
-i : salmon index file
-p : nombre de core (notre macine en a 8 on en met 6)
-o : chemin du dossier d'output
-tgMPap : le tableau de correspondance nom de transcrits - nom de gène

07/11/2019
On cherche le nombre de cellules dans l'article
- 2769 pour la condition WT whole brain (SRR8795649) 
-	4194 pour APP/PS1 whole brain (SRR8795651)
Avec alevin nous trouvons 7381 (418 de plus) cellules pour les deux conditions
--> ils doivent aggréger les barre-codes plus facilement (ou peut-être n'ont pas traité les doublets de la même manière)

