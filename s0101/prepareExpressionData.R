#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# ******************************************************************
# Preprocess gene expression data & tumor purity data
#   - Split into training & testing data
#   - Standardize traning & testing data
#   - Match TCGA RNAseq with tumor purity data from training
#
# Split data into training (TCGA Bulk RNAseq) & testing (single cell)
#   - TCGA: first 134 data
#   - Single cell: last 6 data
#
# Note: 
#   - Assume data from two platforms are in the same unit, ie log2(counts+1)
#
# yuanyuan.li@nih.gov
# created : 10-05-2018
# ******************************************************************
options("expressions"=500000) #max no. nested iterations
require(caret)
require(data.table)
require(vcd)
require(e1071)

in_loc  <- args[1]  # input data location
in_nam  <- args[2]  # combined common gene expression filename
num_tcga_sample <- as.numeric(args[3])  # number of TCGA RNAseq samples
in_pur  <- args[4]  # purity file
out_loc <- args[5]  # output location


#===== 1. Read in data ==========
print('- read data')
# Read in the combined expression file
infile <- paste(in_loc, in_nam, '.value', sep="")
# data is Gene X Sample, need to transform before save. 
data   <- read.table(infile, header=F, row.names=1, sep="\t")
gene   <- row.names(data)

# Read in combined sample ID file
infile <- paste(in_loc, in_nam, '.label',  sep="")
label  <- read.table(infile, header=F, sep="\t")

# Read in TCGA tumor purity file
infile <- paste(in_loc, in_pur, sep="")
purity <- read.table(infile, header=T, sep="\t")


#===== 2. Split into training & testing data =========
print('- split data')
#------- Testing data (new data) -------
# use single cell as testing
idx_tst <- (num_tcga_sample+1):nrow(label)
lbl_tst <- label[idx_tst,] 
dat_tst <- data[,idx_tst]

#------- Training data (TCGA bulk RNAseq data) -------
idx_trn <- 1:num_tcga_sample
lbl_trn <- label[idx_trn, ] 
dat_trn <- data[, idx_trn]


#====== 3. Standardize training & testing data =======
print('- standardize data')
# Get a vector of sample medians from training data (TCGA)
med_trn <- apply(dat_trn, 2, FUN = median)
# Get a vector of sample medians from testing data (single cell)
med_tst <- apply(dat_tst, 2, FUN = median)
# Get median of the sample medians from training data (TCGA)
med_med <- median(med_trn)

# Standardize traning data (TCGA RNAseq)
dat_trn_std <- dat_trn * med_med / med_trn
# Standardize testing data (single cell)
dat_tst_std <- dat_tst * med_med / med_tst


#====== 4. Get traning samples' tumor purity estimates  =======
print('- get tumor purity')
# Match TCGA data with TCGA purity ID 
id_len  <- 16  #TCGA RNAseq ID length
# Only compare the first 16 characters for each sample
sid_pur <- strtrim(purity$sample, id_len)
sid_rna <- strtrim(lbl_trn[,1], id_len)
colnames(dat_trn_std) <- sid_rna
  
# Use matched RNA as traning data
sid_trn<-intersect(sid_rna, sid_pur) 
dat_trn_std_mth<-NULL
lbl_trn_std_mth<-NULL
# match expression & purity values
for (i in 1:length(sid_trn)){
  dat_trn_std_mth <- cbind(dat_trn_std_mth, dat_trn_std[,sid_trn[i]])
  # Get purity values 
  idx     <- which(sid_pur %in% sid_trn[i])
  lbl_trn_std_mth <- rbind(lbl_trn_std_mth, c(sid_trn[i], purity$purity[idx]))
} #end-for


#===== 5. Write data to file ===========
print('- write to file')
ext="_std_trn"
# transpose to sample X gene
dat_trn_std_mth <- t(dat_trn_std_mth)
out_file=paste(out_loc, in_nam, ext, ".value", sep="")
write.table(dat_trn_std_mth, out_file, sep="\t", row.names=F, col.names=F, quote=F)

out_file=paste(out_loc, in_nam, ext, ".label", sep="")
write.table(lbl_trn_std_mth, out_file, sep="\t", row.names=F, col.names=F, quote=F)

out_file=paste(out_loc, in_nam, ext, ".gene", sep="")
write.table(gene, out_file, sep="\t", row.names=F, col.names=F, quote=F)

ext="_std_tst"
# transpose to sample X gene
dat_tst_std <- t(dat_tst_std)
out_file=paste(out_loc, in_nam, ext, ".value", sep="")
write.table(dat_tst_std, out_file,  sep="\t", row.names=F, col.names=F, quote=F)

out_file=paste(out_loc, in_nam, ext, ".label", sep="")
write.table(lbl_tst, out_file,  sep="\t", row.names=F, col.names=F, quote=F)

out_file=paste(out_loc, in_nam, ext, ".gene", sep="")
write.table(gene, out_file, sep="\t", row.names=F, col.names=F, quote=F)


print('- done')

