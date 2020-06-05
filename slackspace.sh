#!/bin/bash
# Variaveis
SAIDA=$(mktemp)
CSV=$(mktemp)
for ((i=1;i<=9;i++)); do
	TEMPORARIOS[$i]=$(mktemp)
done
#
# Teste - Esta certo ou nao
#
if [ $# -ne 1 ]; then
	echo "Syntax: $0 <diretorio>"
	echo "Hey, you must use absolute path!"
	exit 1
fi
#
# Geracao da lista
#
echo "Geracao da lista"
find $1 -type f -exec du -b {} \; | cut -f1 -s > ${TEMPORARIOS[7]} 
TOTAL_ARQUIVOS=$(cat ${TEMPORARIOS[7]} | wc -l)
TOTAL_TAMANHO=$(awk '{ soma += $1 } END { print soma }' ${TEMPORARIOS[7]})
echo "There are $TOTAL_ARQUIVOS files, which uses $TOTAL_TAMANHO bytes."
#
# Calculo da tamanho dos clusters
#
echo "Calculating clusters' size..."
CLUSTER[1]=2048
for ((i=2;i<=6;i++)); do
	CLUSTER[$i]=$((CLUSTER[$i-1]*2))
done
#
# Calculo da quantidade de clusters e slack space
#
echo "Calculating how many clusters and slack space..."
for ((i=1;i<=6;i++)); do
	awk -v c=${CLUSTER[$i]} '{ print $1/c }' ${TEMPORARIOS[7]} >> ${TEMPORARIOS[$i]}
	cat ${TEMPORARIOS[$i]} | cut -f1 -d"." > ${TEMPORARIOS[8]}	
	awk '{ $1++ ; print $0 }' ${TEMPORARIOS[8]} > ${TEMPORARIOS[9]}
	TAMANHO[$i]=$(awk '{ soma += $1 } END { print soma }' ${TEMPORARIOS[7]})
	NUMERO_DE_SETORES[$i]=$(awk '{ soma += $1 } END { print soma }' ${TEMPORARIOS[9]})
	TAMANHO_SLACK[$i]=$((NUMERO_DE_SETORES[$i] * CLUSTER[$i]))
	echo "${CLUSTER[$i]} ${TAMANHO[$i]} ${TAMANHO_SLACK[$i]} ${NUMERO_DE_SETORES[$i]}" >> $SAIDA
done
#
# Apresentacao do resultado
#
#printf"Cluster,Particao,No. de clusters,Espaco s/ slack space,Espaco s/ slack space (escala),Espaco c/ slack space,Espaco c/ slack space (escala)" > $CSV
j=0
printf "Results:\n"
cat $SAIDA | while read LINHA
do
	CLUSTER=$(echo $LINHA | cut -f1 -d" ")
	TOTAL_TAMANHO=$(echo $LINHA | cut -f2 -d" ")
	TOTAL_SLACK=$(echo $LINHA | cut -f3 -d" ")	
	TOTAL_CLUSTERS=$(echo $LINHA | cut -f4 -d" ")
	SLACK_ESCALA=$TOTAL_SLACK
	SLACK_MEDIDA=$TOTAL_SLACK
	TAMANHO_ESCALA=$TOTAL_TAMANHO
	ESCALA[1]="bytes"
	ESCALA[2]="Kbytes"
	ESCALA[3]="Megabytes"
	ESCALA[4]="Gigabytes"
	PARTICAO[1]="128 Mb"
	PARTICAO[2]="256 Mb"	
	PARTICAO[3]="512 Mb"
	PARTICAO[4]="1 Gb"
	PARTICAO[5]="2 Gb"
	PARTICAO[6]="4 Gb"
	i=0
	while [ $SLACK_MEDIDA -gt 0 ]
	do
		ANTERIOR1=$SLACK_ESCALA
		ANTERIOR2=$TAMANHO_ESCALA
		i=$((i+1))
		SLACK_MEDIDA=$((SLACK_MEDIDA / 1024))		
		SLACK_ESCALA=$(echo "scale=2 ; $SLACK_ESCALA / 1024" | bc)
		TAMANHO_ESCALA=$(echo "scale=2 ; $TAMANHO_ESCALA / 1024" | bc)		
	done
	SLACK_ESCALA=$ANTERIOR1
	TAMANHO_ESCALA=$ANTERIOR2
	MEDIDA=${ESCALA[$i]}
	j=$((j+1))
#	
	printf "Cluster: $CLUSTER bytes (${PARTICAO[$j]}); Clusters: $TOTAL_CLUSTERS; Space without slack space: $TOTAL_TAMANHO bytes ($TAMANHO_ESCALA $MEDIDA); space with slack space: $TOTAL_SLACK bytes ($SLACK_ESCALA $MEDIDA)\n"
#	printf "$CLUSTER,${PARTICAO[$j]},$TOTAL_CLUSTERS,$TOTAL_TAMANHO,$TAMANHO_ESCALA $MEDIDA,$TOTAL_SLACK,$SLACK_ESCALA $MEDIDA" >> $CSV
done
#
# MSX r0x a lot.
