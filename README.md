# NGS_Practicals_scRNA

05/11/2019
On s'est donnée la permission de modifier le disk
- sudo chown :rstudio:rstudio disk

On a cloné le dépôt avec les squelettes de script 
- git clone ADRESSE

On a crée le git sur github
Pour enregistrer un nouveau git il faut : 
- git add FICHIER
- git commit -m "comm"
- git push 

On a modifié le fichier script_fastqdump.bash afin de télecharger quelques données de l'article 
--> 16 months WT whole brain (SRR8795649) and 16 months APP/PS1 whole brain (SRR8795651)
- fastqdump va chercher dans NCBI GEO
- -X 100000 : telecharge les 1000000 premiers reads de chaque condition
- --split-files : sépare les trois reads (read du barcode, read séquence, read du pool(pool plsr conditions et etiquette les cDNA pour savoir à quelles conditions ils appartiennent))