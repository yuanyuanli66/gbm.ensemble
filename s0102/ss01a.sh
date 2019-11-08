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
echo "rm $out_loc/*"



# Cross validation for initial grid search 
echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 xgboost_tuneParam_cv.R  $in_loc_02  $in_name_02 $idx_start $idx_end $num_thread_02 $out_loc > $out_loc/output.log  2>&1 &"
#echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 xgboost_tuneParam_cv.R  $in_loc_02  $in_name_02 $idx_start $idx_end $num_thread_02 $out_loc > $out_loc/output.log  2>&1 &"
#echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 xgboost_tuneParam_cv_refined.R  $in_loc_02 $in_name_02 $idx_start $idx_end $num_thread_02 $out_loc > $out_loc/output.log  2>&1 &"




