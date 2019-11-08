####################################################
# s0103.sh Build XGBoost ensemble with repeated CV
# Predict testing set tumor purity
####################################################
source ../env_var.sh

l_dir=${PWD##*/}
out_loc="$gb_loc/$l_dir/"
echo "mkdir $out_loc"
echo "rm $out_loc/*"


# Train XGBoost model and predict test set
echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 xgboost_regression.R  $in_loc_s03 $in_name_s03 $out_loc $nfold $nrepeats $ntrees $nstop $max_depth  $min_cw  $eta  $colsample_bytree  $subsample $seed $num_thread_s03 > $out_loc/output.log  2>&1 & "

