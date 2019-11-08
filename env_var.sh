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
in_loc_s02="$gb_loc/s0101/"
in_name_s02="common_tcga_singlecell_tnbc_std_trn"
num_thread_s02="64" # number of threads for parallel execution

# Starting & ending index of parameter combo
#  - If want to run on multiple servers, do
#     - duplicate local shell script file in s0102 for each server (>cp ss01a ss02a)
#     - specify start & end index of combos to run on that server
#     - update Makefile 
idx_start="1"
idx_end="25"    # 25 parameter combos in the small demo
#idx_end="1344" # 1344 parameter combos in the initial grid search  


#------- s0103 parameters ---------
in_loc_s03="$gb_loc/s0101/"
in_name_s03="common_tcga_singlecell_tnbc_std"
num_thread_s03="64" # number of threads for parallel execution


nfold="10"       # k-fold cv
#nrepeats="100"   # repeated cross-validationc (10x100=1000 models)
nrepeats="10"   # repeated cross-validation (faster)
#ntrees="5000"   # max number of boosted trees
ntrees="100"     # max number of boosted trees (faster)
nstop="5"        # early stopping criteria
seed="1000"      # starting seed number


# best parameter combo found in step 2
max_depth="6"            # max tree depth
min_cw="10"              # min leaf weight
eta="0.01"               # learning rate
colsample_bytree="0.75"  # percentage of feature (gene) per tree used
subsample="0.40"         # percentage of samples used





#----- misc: TCGA tumor code -------
all_tum_lst=("acc" "blca" "brca" "cesc" "chol" "coad" "dlbc" "esca" 
             "gbm" "hnsc" "kich" "kirc" "kirp" "laml" "lgg" "lihc" 
             "luad" "lusc" "meso" "ov" "paad" "pcpg" "prad" "read" 
             "sarc" "skcm" "stad" "tgct" "thca" "thym" "ucec" "ucs" "uvm")
all_tum_lst_len=${#all_tum_lst[*]}





