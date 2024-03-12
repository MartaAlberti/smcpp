# SCRIPT TO GENERATE COMPLEMENTED MASK FILES FOR hg38 for 1000 Genomes

# The accessibility mask file in .bed format -> https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/working/20160622_genome_mask_GRCh38/StrictMask/
# downloaded with command:
wget ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/working/20160622_genome_mask_GRCh38/StrictMask/20160622.allChr.mask.bed


#------------- PREPARE MASK FILES
# first separate the *.mask.bed file by chromosome in order to have one mask file for each chromosome
for k in {1..22} ; do grep ^chr$k 20160622.allChr.mask.bed > 20160622.chr${k}.mask.bed ; done

# create file chr_lengths_hg38.txt by taking the lengths from -> https://www.ncbi.nlm.nih.gov/grc/human/data
# starting from chr_lengths.txt we have to prepare files formatted as: 'chrK	length_chrK' which are necessary to complement each mask file
# to do so, extract $1 (chr_number) and $2 (chr_length) from chr_lengths.txt, remove the ',' so lengths are expressed as 50818468 (instead of 50,818,468)
for k in {1..22} ; do awk -v chr=$k '$1==chr {print "chr"$1"\t"$2}' chr_lengths.txt | tr -d ',' > chr_${k}.genome; done

# complement each chromosome's mask file with respect to the chromosome's genome
for k in {1..22} ; do bedtools complement -i 20160622.chr${k}.mask.bed -g chr_${k}.genome > chr_${k}_hg38_mask_complemented_1kG.bed ; done

# remove 'chr' from each line
for k in {1..22}; do tr -d 'chr' < chr_${k}_hg38_mask_complemented_1kG.bed > chr_${k}_hg38_mask_complemented_final_1kG.bed ; done

# zip and create index for each chr_${k}_hg38_mask_complemented_final_1kG.bed
for k in {1..22} ; do bgzip chr_${k}_hg38_mask_complemented_final_1kG.bed ; done
for k in {1..22} ; do tabix -p bed chr_${k}_hg38_mask_complemented_final_1kG.bed.gz ; done