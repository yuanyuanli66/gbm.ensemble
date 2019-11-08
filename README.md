# Predict tumor purities using TCGA RNAseq data
This is a small demo based on using TCGA's Tripple Negative Breast Cancer (TNBC) RNA-seq to build 
an ensemble of gradient boosting machines and use the enseble model to predict tumor purities in 
TNBC single-cell data.  
 
## Installation
Make sure you have R 3.4 or newer. 
 
You can install ``caret``, ``xgboost``,``MLmetrics``,``data.table``,``vcd``, and ``e1071`` packages under R. 
 
The following pipeline runs on Linux (or Linux-like) environment using a Makefile. 
 
 
## Running the demo
Make sure you set up the classpath in ``env_var.sh`` file
 
```
tb_loc="~/your_path/gbm.ensemble-master/"        # code path
db_loc="~/your_path/gbm.ensemble-master/input/"  # input path
gb_loc="~/your_path/gbm.ensemble-master/output/" # output path
 
```
 
After classpath is set, you can use ``make`` to check if your running commands are set correctly. 
 
```
LINUX> make  prepareTNBCbulkRNAandSingleCell
LINUX> make  findXgbParamTNBCbulkRNAandSingleCell
LINUX> make  predictViaRepeatedCvXgbTNBCbulkRNAandSingleCell
 
```
 
To run the 3-step pipeline, you can use the following commands:
 
```
LINUX> make  prepareTNBCbulkRNAandSingleCell | bash
LINUX> make  findXgbParamTNBCbulkRNAandSingleCell | bash
LINUX> make  predictViaRepeatedCvXgbTNBCbulkRNAandSingleCell | bash
 
```
 
Note: The step 2: ``make  findXgbParamTNBCbulkRNAandSingleCell | bash`` is optional. 
This step may take a long time. You can skip this step and go to the prediction (step 3) directly.
 
 
## Running this pipeline with your own gene expression data
You will need to download the TCGA RNAseq data for your tumor type. 
In the ``./input`` subfolder,  you need to generate your own ``.value`` and ``.label`` files in the 
same format as ``common_tcga_singlecell_tnbc.value`` and ``common_tcga_singlecell_tnbc.label`` files. 

 * ``.value`` file contains the gene name and gene expression values of both TCGA RNAseq data and your gene expression data that you want to predict

 * ``.label`` file contains the TCGA sample ID (minimum of 16 characters) and your expression data sample ID and a column of integers (can be any)

 


