# SCRIPT TO GENERATE COMPLEMENTED MASK FILES FOR hg38 for HGDP

# The accessibility mask file in .bed format -> https://ngs.sanger.ac.uk/production/hgdp/hgdp_wgs.20190516/accessibility-mask/
# dowloaded with command:
wget ftp://ngs.sanger.ac.uk/production/hgdp/hgdp_wgs.20190516/accessibility-mask/*.bed


#------------- PREPARE MASK FILES
# first separate the *.mask.bed file by chromosome in order to have one mask file for each chromosome
for k in {1..22} ; do grep ^chr$k hgdp_wgs.20190516.mask.bed > hgdp_wgs.20190516_chr${k}.mask.bed ; done

# create file chr_lengths_hg38.txt by taking the lengths from -> https://www.ncbi.nlm.nih.gov/grc/human/data
# starting from chr_lengths.txt we have to prepare files formatted as: 'chrK    length_chrK' which are necessary to complement each mask file
# to do so, extract $1 (chr_number) and $2 (chr_length) from chr_lengths.txt, remove the ',' so lengths are expressed as 50818468 (instead of 50,818,468)
for k in {1..22} ; do awk -v chr=$k '$1==chr {print "chr"$1"\t"$2}' chr_lengths_hg38.txt | tr -d ',' > chr_${k}_hg38.genome; done

# complement each chromosome's mask file with respect to the chromosome's genome
for k in {1..22} ; do bedtools complement -i hgdp_wgs.20190516_chr${k}.mask.bed -g chr_${k}_hg38.genome > chr_${k}_hg38_mask_complemented_HGDP.bed ; done

#create index for chr_${k}_hg38_mask_complemented_HGDP.bed
for k in {1..22} ; do bgzip chr_${k}_hg38_mask_complemented_HGDP.bed ; done
for k in {1..22} ; do tabix -p bed chr_${k}_hg38_mask_complemented_HGDP.bed.gz ; done
