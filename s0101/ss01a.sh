##################################################################
# s0101.sh Single cell purity prediction for BRCA triple negative
# - standardize data
# - creat traning & testing data sets 
##################################################################
source ../env_var.sh

l_dir=${PWD##*/}
out_loc="$gb_loc/$l_dir/"
echo "mkdir $out_loc"
#echo "rm $out_loc/*"



#---------- preprocess data ---------
echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 prepareExpressionData.R  $db_loc $filename $num_tcga_sample $tcga_pur $out_loc > $out_loc/output.log  2>&1 &"

