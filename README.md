# Predict single cell tumor purities using TCGA bulk RNAseq data

## Installation
Make sure you have R 3.4 or newer. 

You can install ``caret``, ``xgboost``,``MLmetrics``,``data.table``,``vcd``, and ``e1071`` packages installed under R. 

The following pipeline runs on linux (or linux-like) environment using a Makefile. 


## Running the demo
Make sure you setup the classpath in ``env_var.sh`` file

```
tb_loc="~/your_path/gbm.ensemble-master/"        # code path
db_loc="~/your_path/gbm.ensemble-master/input/"  # input path
gb_loc="~/your_path/gbm.ensemble-master/output/" # output path

```

After classpath is set, you can use ``make`` to check if your commands are setup correctly. 

```
LINUX> make  prepareTNBCbulkRNAandSingleCell
LINUX> make  findXgbParamTNBCbulkRNAandSingleCell
LINUX> make  predictViaRepeatedCvXgbTNBCbulkRNAandSingleCell

```

To run the 3-step pipeline, you can use the following commands.

```
LINUX> make  prepareTNBCbulkRNAandSingleCell | bash
LINUX> make  findXgbParamTNBCbulkRNAandSingleCell | bash
LINUX> make  predictViaRepeatedCvXgbTNBCbulkRNAandSingleCell | bash

```

Note: Step 2: ``make  findXgbParamTNBCbulkRNAandSingleCell | bash`` is optional. 
This step may take a long time. You can skip this step and go to prediction (step 3) directly.




