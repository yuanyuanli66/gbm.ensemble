##################################################################
# s0101.sh Single cell purity prediction for BRCA triple negative
#   - creat traning & testing data sets 
#   - standardize data
#   - get avaliable TCGA tumor purity estimates for TCGA RNAseq data
##################################################################
source ../env_var.sh

echo "mkdir $gb_loc"       # make output folder if it is not there

l_dir=${PWD##*/}           # get current subfolder name
out_loc="$gb_loc/$l_dir/"  # set output subfolder
echo "mkdir $out_loc"      # make output subfolder
echo "rm $out_loc/*"       # remove pre-existing files in the output subfolder


#---------- preprocess data ---------
echo "nohup Rscript --no-save --no-restore --verbose --max-ppsize=500000 prepareExpressionData.R  $db_loc $filename $num_tcga_sample $tcga_pur $out_loc > $out_loc/output.log  2>&1 &"

