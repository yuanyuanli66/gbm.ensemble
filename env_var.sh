#------- set classpath ---------
#tb_loc="~/your_path/gbm.ensemble-master/"        # code path
#db_loc="~/your_path/gbm.ensemble-master/input/"  # input path
#gb_loc="~/your_path/gbm.ensemble-master/output/" # output path
tb_loc="~/gt/gbm.ensemble-master/"        # code path
db_loc="~/gt/gbm.ensemble-master/input/"  # input path
gb_loc="~/gt/gbm.ensemble-master/output/" # output path


#------- s0101 parameters ---------
# Combined gene expression values file (gene by sample)
#   - TCGA TNBC RNAseq (first portion) followed by single cell (last portion)
filename="common_tcga_singlecell_tnbc"
# Number of TCGA TNBC samples
num_tcga_sample="134"

# TCGA tumor purity 
#   - Reference: [Hoadley, et al, Cell, 2018]
tcga_pur="tcga_array_sample_purity.txt"



#------- s0102 parameters ---------
# location and name of the training file
in_loc_02="$gb_loc/s0101/"
in_name_02="common_tcga_singlecell_tnbc_std_trn"

# Starting & ending index of parameter combo
idx_start="1"
idx_end="1344"  # can be smaller if want to run into multiple batches on seperate computers
num_thread_02="64" # number of threads for parallel execution


#------- s0103 parameters ---------
nfold="10"       # k-fold cv
#nrepeats="100"   # repeated cross-validation
nrepeats="10"   # repeated cross-validation (faster)
#ntrees="5000"   # max number of boosted trees
ntrees="500"     # max number of boosted trees (faster)
nstop="5"        # early stopping criteria
seed="1000"      # starting seed number


max_depth="6"            # max tree depth
min_cw="10"              # min leaf weight
eta="0.01"               # learning rate
colsample_bytree="0.75"  # percentage of feature (gene) per tree used
subsample="0.40"         # percentage of samples used





#----- others: TCGA tumor code -------
all_tum_lst=("acc" "blca" "brca" "cesc" "chol" "coad" "dlbc" "esca" 
             "gbm" "hnsc" "kich" "kirc" "kirp" "laml" "lgg" "lihc" 
             "luad" "lusc" "meso" "ov" "paad" "pcpg" "prad" "read" 
             "sarc" "skcm" "stad" "tgct" "thca" "thym" "ucec" "ucs" "uvm")
all_tum_lst_len=${#all_tum_lst[*]}




