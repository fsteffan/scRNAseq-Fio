# NGS_Practicals_scRNA


############################### Première semaine ##########################################
05/11/2019
Dans le terminal
On s'est donnée la permission de modifier le disk
#sudo chown :rstudio:rstudio disk

On a cloné le dépôt avec les squelettes de script 
#git clone ADRESSE

On a crée le git sur github
Pour enregistrer un nouveau git il faut : 
#Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
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

On l'execute en nohub pour pouvoir faire autre chose à côté et que ca soit indépendant si ca crash
#nohup ./SCRIPT & (on doit se situer à l'endroit du script)



07/11/2019
On cherche le nombre de cellules dans l'article
- 2769 pour la condition WT whole brain (SRR8795649) 
-	4194 pour APP/PS1 whole brain (SRR8795651)
Avec alevin nous trouvons 7381 (418 de plus) cellules pour les deux conditions
--> ils doivent aggréger les barre-codes plus facilement (ou peut-être n'ont pas traité les doublets de la même manière)


ENSEMBL --> genome publiéq 
  BioMart : ensembl gene, mouse genes
  
On commence l'analyse scRNAseq grâce à Seurat
(scRNAseq_analysis.Rmd)
On importe nos données de quantification d'Alevin.
On visualise le nombre d'UMI, de gènes et de gènes mitochondriaux par cellules. Avec Seurat, on fera un trie pour garder les gènes et cellules plausibles et en bonnes santées (UMI pas trop haut ni trop bas, gène mitochondriaux pas trop élevés ..)
 
#################################### Deuxième semaine ########################################
16/12/19
On se refamiliarise avec le code et on continue l'analyse scRNAseq
(scRNAseq_analysis)
La première semaine nous avions commencer à analyser les deux conditions en même temps car nous avions fait tourner alevin sur les deux conditions ensemble mais nous n'avions pas de moyen de les différencier. Nous avons donc recommencer l'analyse en séparant la condition WT et APP/PS1.

On commence l'analyse avec Seurat.
- On crée deux objets Seurat différents selon les deux conditions (seurat_WT et seurat_APP).
- Ensuite on 'nettoye' les données en ne conservant que les cellules exprimant entre 200 et 2500 RNA et dont le pourcentage d'ARN mitochondrial est inférieur à 10%.
- Puis on normalise les niveaux d'expression de gènes d'une cellule par rapport aux autres gènes de la cellule.
- On visualise ensuite les gènes les plus différentiellement exprimés dans les cellules et on compare les deux conditions. On retrouve des gènes connus de l'immunologie: des cytokines, du CMH etc ..
- On va effectuer des PCA et pour ceci il faut d'abord 'scaler' les données

A la fin de cette journée on réflechit et en parlant avec Marie on réalise qu'il faut qu'on fasse l'analyse des deux conditions ensemble sur Seurat afin de pouvoir les comparer. Il faut donc créer un objet Seurat combinant les deux résulats alevin correspondant aux deux conditions WT et APP/PS1. On pourra ensuite "étiquetter" les cellules provenant des deux conditions pour pouvoir comparer les résulats des tSNE et UMAP.



17/12/19
On essaye donc de créer un objet Seurat combinant les résulatst d'alevin pour la condition WT et APP.
C'est la journée des problèmes. Valentine et moi n'avions pas gitpush le jour précédent et le code de Valentine bug avec des parties qui s'effacent. Je lui envoie mon code pour le fichier scRNAseq_analysis.
Avant de gitpush mon fichier, une partie du code s'est supprimé, je ne comprends pas comment. Valentine m'envoie donc son script que je remplace dans mon fichier scRNAseq_analysis.Ce fichier est donc un aptchwork de mon ancien script et de son script.

Il y a également une coupure de courant à cause de la grève qui nous empêche d'accéder à nos machines.
On travail sur notre présentation de demain.
Finalement, on codera le reste de notre code sur l'ordinateur de Marie pour cette journée.



18/12/19
On crée un nouveau ficier (New_NGS.Rmd) qui va correspondre à notre fichier final dans lequel on combine notre première analyse (scRNAseq_analysis.Rmd) avec notre code sur l'ordinateur de Marie du jour précédent.

- Après avoir importé les deux output d'alevin correspondant à WT et APP, on crée une matrice qui joint les tables de compte résultantes des conditions WT et APP. Pour pouvoir identifier quelle cellule appartient à quelle conditions, on crée une liste (cell) comportant "WT" répété le nombre de ligne de la table de compte WT et "APP" de manière idem.
- On crée une matrice metadata pour identifier les cellules dans l'objet seurat
#metaData <- data.frame("cells"=colnames(rawData),row.names="cells",stringsAsFactors=FALSE)
#metaData$orig.ident <- cells
- Lorsque l'on crée l'objet Seurat, on lui joint ce metadata
#seuratObj <- CreateSeuratObject(counts=rawData,project="seuratObj",min.cells=3,min.features=200,meta.data=metaData)
- Après avoir nettoyer, normaliser, et effectuer les PCA comme précédemment décrit le 16/12/19, on doit déterminer quelles sont les composents informatifs de la PCA = déterminer la dimensionalité. Cela signifie que l'on identifie le nombre d'axe de PCA relevant pour séparer les cellule en groupes de cellules proches transcriptionnellement.
Pour cela, on utilise JackStraw et Elbow. Sur la courbe du coude (Elbowplot), on identifie la dimensionalité autour de 15. On gardera dimensionalité=15 pour la suite de l'analyse.
- Pour le clustering, on utilise l'algorithme : FindNeighbors qui regroupe les cellules qui partagent le plus les mêmes cellules voisines. Cet alogrithme résulte en un groupement visuel des cellules. Pour identifier des cluster au sein de ces groupement de cellules on utilise un autre algoritme : FindClusters. E jouant sur la résolution (correspondant à la perplexité) on peut définir un certain degré de précision dans les cluster. Plus la résoluation est haute, plus on aura de clusters, plus la découpe est précise. Ils'agit de trouver des cluster relevant biologiquement.
On utilise une résolution de r=0.4
Avec cette résolution j'ai trouve 14 cluster mais Valetine en a trouve 16. On ne comprend pas pourquoi. Les représentations des cellules ne correspondent également pas à celle qu'on avait observé su l'ordinateur de Marie hier. Il y a une part de stochasticité qui rend difficile la reproducibilité.
- On peut ensuite visualiser en tSNE en découplant les conditions WT et APP. 
Nos objectif avant la présentation sont : 
1) identifier les différents clusters
2) identifier les clusters qui différent les plus entre les cellules immunes du cerveau WT et APP (modèle Alzheimer)
- Pour identifier les différents clusters, on peut trouver les 4 premiers marqueurs des clusters grâce à 
#seuratObj.markers <- FindAllMarkers(seuratObj, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
#seuratObj.markers  %>% group_by(cluster) %>% top_n(n = 4, wt = avg_logFC)
Grâce à ces marqueur son peut identifier des types cellulaires mais ils ne sont parfois pas assez spécifiques.
On effectue donc la méthode inverse, on recherche lesmarqueurs que nous connaissons qui sont spécifiques de types de cellules immunitaire (CD4, CD8, Ly6g, B220 etc ??) grâce à
#grep(x=all.genes, "Cd11c") 
et on regarde s'ils sont spécifique d'un cluster grâce à un violinplot ou directement en tSNE
#VlnPlot(seuratObj, features = "Cd11c")
#FeaturePlot(seuratObj, reduction ="tsne", features = "Cd11c")

Nous avons réussi à identifier la majorité des clusters.
Merci Marie !