#!/bin/bash

if [[ -d files ]]; then
    exit
fi

mkdir -p files
cd files

# metamorphosis
wget -O metamorphosis.txt https://www.gutenberg.org/cache/epub/5200/pg5200.txt
wget -O words.txt https://users.cs.duke.edu/~ola/ap/linuxwords
wget -O word_counts.txt https://www.kilgarriff.co.uk/BNClists/lemma.al

# sample vcf
wget -O sample.vcf https://raw.githubusercontent.com/vcflib/vcflib/master/samples/sample.vcf
# sample fasta, need to parse from html
wget -O - https://www.bioinformatics.nl/tools/crab_fasta.html | \
    awk 'BEGIN {RS="<pre>"; FS="\n"} {if (NR == 4) {for (i=2; i < NF; i++){ if($i ~ /^<\/pre>/) exit; print $i}}}' \
    | dos2unix \
    > sample.fasta
wget -O human.chrom.sizes http://hgdownload.cse.ucsc.edu/goldenpath/hg19/bigZips/hg19.chrom.sizes
