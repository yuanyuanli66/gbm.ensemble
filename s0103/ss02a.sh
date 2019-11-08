####################################################
# s2803.sh XGB with repeated CV
####################################################
source ../env_var.sh

l_dir=${PWD##*/}
out_loc="$gb_loc/$l_dir/Do/"
out_info="$gb_loc/$l_dir/Di/"

in_loc="$gb_loc/s2801/Do/"
file_lst=(
  "tnbc_commone_genes_tcga_singlecell_2_matched"
  )
file_lst_len=${#file_lst[*]}

nfold="10"       # k-fold cv
nrepeats="100"   # repeated cross validation
ntrees="5000"    # max num of boosted trees
nstop="5"        # early stopping criteria
seed="1000"      # starting seed number

#@param: 5000  6 10 0.01  0 0.75 0.4
#@res:  id best_itr_mu best_itr_sd tst_rmse_mu tst_rmse_sd  trn_rmse_mu
#6  6      1093.8     541.174   0.1338762  0.03067782  0.02209948  0.00645281
#  tst_r2_mu tst_r2_sd trn_r2_mu  trn_r2_sd tst_cor_mu tst_cor_sd trn_cor_mu
#6 0.5032449 0.1460096 0.9857714 0.00695128  0.7386001   0.109944  0.9946917
#  trn_cor_sd
#6 0.00267513

#@param: 5000  6 10 0.01  0  1 0.4
#@res:  id best_itr_mu best_itr_sd tst_rmse_mu tst_rmse_sd  trn_rmse_mu
#11 11      1180.4    768.6293   0.1333219  0.03195091  0.02206792  0.00730009
#   tst_r2_mu tst_r2_sd trn_r2_mu  trn_r2_sd tst_cor_mu tst_cor_sd trn_cor_mu
#11 0.5034815 0.1673416 0.9855018 0.00722606  0.7372488  0.1203037  0.9946443
#   trn_cor_sd
#11 0.00279326

max_depth="6"
min_cw="10"
eta="0.01"
colsample_bytree="0.75"
subsample="0.40"

f=0
#for a in `seq 0 1 $((${file_lst_len}-1))`; do
   echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 yyl_xgboost_regression.R  $in_loc ${file_lst[$f]} $out_loc $nfold $nrepeats $ntrees $nstop $max_depth  $min_cw  $eta  $colsample_bytree  $subsample $seed > $out_info/${file_lst[$f]}.log  2>&1 &"
#done


