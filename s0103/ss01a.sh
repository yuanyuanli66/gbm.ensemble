####################################################
# s0103.sh Build XGBoost ensemble with repeated CV
# Predict testing set tumor purity
####################################################
source ../env_var.sh

l_dir=${PWD##*/}
out_loc="$gb_loc/$l_dir/"
echo "mkdir $out_loc"

in_loc="$gb_loc/s0101/"
in_name="common_tcga_singlecell_tnbc_std"
#echo "rm $out_loc/*"

num_thread="64" # number of threads for parallel execution


# Train XGBoost model and predict test set
echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 xgboost_regression.R  $in_loc $in_name $out_loc $nfold $nrepeats $ntrees $nstop $max_depth  $min_cw  $eta  $colsample_bytree  $subsample $seed $num_thread > $out_loc/output.log  2>&1 & "

