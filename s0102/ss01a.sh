#######################################################################
# s0102.sh Parameter tuning using training data 
#  - Grid search via 10-fold cv
#  - Initial grid search
# Note: 
#   - Initial grid size is 1344
#   - Each parameter combo can be run independently
#   - Use idx_start & idx_end as checkpoints 
#        if choose to run this procedure using multiple servers
#   - Can do a localized search round the best parameter combo 
#######################################################################
source ../env_var.sh

l_dir=${PWD##*/}
out_loc="$gb_loc/$l_dir/"
echo "mkdir $out_loc"
#echo "rm $out_loc/*"

# location of training file
in_loc="$gb_loc/s0101/"
in_name="common_tcga_singlecell_tnbc_std_trn"

# Starting & ending index of parameter combo
idx_start="1"
idx_end="1344"  # can be smaller if want to run into multiple batches
num_thread="64" # number of threads for parallel execution


# Cross validation for initial grid search 
echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 xgboost_tuneParam_cv.R  $in_loc  $in_name $idx_start $idx_end $num_thread $out_loc > $out_loc/output.log  2>&1 &"

#echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 xgboost_tuneParam_cv_refined.R  $in_loc $in_name $idx_start $idx_end $num_thread $out_loc > $out_loc/output.log  2>&1 &"




