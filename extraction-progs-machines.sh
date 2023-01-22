#---------------------------------------------------------#
# Those ugly but functional script are published under GNU General Public License v3.0
#Free to use and share
#https://github.com/aluminum1040/NUM-lathe-milling-machines-programs-Extraction-tool


#mettre les fichiers bruts de sauvegarde dans mémoire des machines dans le même dossier que ce script
#avoir les fichiers mémoire bruts avec extension .txt en minuscules
#vérifier que le script renommage.sh est aussi dans ce même dossier
#---------------------------------------------------------#


#"alias" cd car peut pas utiliser cd dans script
# fcdj : fonction cd $j
fcdj()
{
   cd "$j"
}

#enregistrement répertoire de départ dans variable
pwd1=`pwd`

#suppression dernière ligne de chaque fichier brut
for e in *.txt ; do head -$(wc -l "$e" | sed 's/ .*$//') "$e" > "$e".head.brut.txt ; done

#création des dossiers de destination (1 dossier par machine)
for g in *brut.txt ; do mkdir "${g%.txt}-pgms" ; done

#découpage par programme
for h in *brut.txt; do csplit --quiet --prefix=./"${h%.txt}-pgms"/"${h%.txt}.1st.tmptxt" "${h}" "/%/+0" "{*}" ; done
#--digits=3 optionnel

##nettoyage des caractères NUL du début jusqu'au 1er % de chaque prog extrait
for f in ./*-pgms/*1st* ; do cat "$f" | sed 's/.*%/%/' > "$f.sed.tmptxt"; done
#remplacement fin de ligne CRLF par LF pour étapes suivantes en environnement Unix
for i in ./*-pgms/*.sed.tmptxt; do cat "$i" | sed -e 's/\r//g' > "${i}".CRLF-LF.tmptxt ; done

#copie du script de renommage des programmes découpés dans chaque dossier de destination
# + copie du caractère dc3 de fin de transfert vers machine "petité carré" en vue de son ajout en fin de prog plus tard dans ce script
for j in *-pgms ; do cp renommage-head-1.sh "$j/renommage.sh" ; cp petit-carre-dc3 "$j/dc3" ; done

#lancement du script de renommage dans chaque dossier de destination grâce à la fonction de déplacement fcdj
for j in *-pgms ; do "fcdj" ; bash renommage.sh ; cd "$pwd1" ; done

#renommage du fichier contenant les jauges
for j in *-pgms ; do "fcdj" ; mv %.tmptxt ${j%.txt.head.brut-pgms}.jauges.ngc ; cd "$pwd1" ; done 2> /dev/null

#ajout du caractère dc3 en fin de prog, pour un éventuel transfert ordinateur vers machine
for j in *-pgms ; do "fcdj" ; (for k in %*.tmptxt ; do cat "$k" "dc3" > "$k".dc3.tmptxt ; done); cd "$pwd1" ; done

#enlèvement du caractère % en début de nom de fichiers, pour systèmes de fichiers pas compatibles avec ce caractère
for j in *-pgms ; do "fcdj" ; (for l in %*.dc3.tmptxt ; do mv "$l" "${l/\%/}" ; done); cd "$pwd1" ; done

#renommage extension ngc + suppression chaine de caractères en trop '.tmptxt'
for j in *-pgms ; do "fcdj" ; (for m in *.dc3.tmptxt ; do mv "$m" "${m%\.dc3\.tmptxt}".ngc ; done); cd "$pwd1" ; done
for j in *-pgms ; do "fcdj" ; (for n in *.tmptxt.ngc ; do mv "$n" "${n/\.tmptxt/}" ; done); cd "$pwd1" ; done

#suppression fichiers temporaires
find "$pwd1" -iname *.tmptxt* -exec rm {} \;
find "$pwd1" -iname "*brut.txt" -exec rm {} \;
find "$pwd1" -iname dc3 -exec rm {} \;
find "$pwd1" -iname renommage.sh -exec rm {} \;