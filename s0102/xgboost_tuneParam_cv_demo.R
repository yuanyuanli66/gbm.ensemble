#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# ******************************************************************
# Train a regression model for tumor purity using all RNAseq data
#   - K-folds CV training K-folds=SampleSize
#   - No testing  
# This is a refined search around best parameter combo from grid1
#
# yuanyuan.li@nih.gov
# created : 11-06-2019
# ******************************************************************
options("expressions"=500000) #max no. nested iterations
require(caret)
require(xgboost)
require(MLmetrics)
require(data.table)
require(vcd)
require(e1071)


in_loc  <- args[1]
in_name <- args[2]
idx_s   <- as.numeric(args[3])
idx_e   <- as.numeric(args[4])
nthread <- as.numeric(args[5])
out_loc <- args[6]



MAX_LBL=0.9975 # Make sure never == 1
seed_num=998
nfold=10       # k-fold cv
#ntrees=5000    # max num of boosted trees
ntrees=500    # max num of boosted trees
nstop=5        # early stopping criteria


# ===== xgBoost parameter grid search  ====
xgb_grid = expand.grid(
  nrounds          = ntrees,
  max_depth        = c(6),
  min_child_weight = c(10),
  eta              = c(0.01),
  gamma            = 0,
  colsample_bytree = c(0.6,0.65,0.7,0.75,0.8),
  subsample        = c(0.35,0.4,0.45,0.5,0.55)
)

grid_num="gridDemo"
out_file=paste(out_loc,in_name,".",grid_num, sep="")
write.table(xgb_grid, out_file,  sep="\t", row.names=F, col.names=F, quote=F)

#===== Read in data ======
print('- read data')
# Read in the combined expression file
infile <- paste(in_loc, in_name, '.value', sep="")
data   <- read.table(infile, header=F, sep="\t")
data   <- data.matrix(data)   # Sample X Gene

# Read in combined sample ID file
infile <- paste(in_loc, in_name, '.label',  sep="")
label  <- read.table(infile, header=F, sep="\t")
lbl    <- label$V2 # Purity value [0, 1]


#===== Y Transformation ======
print('- transform data')
lbl[lbl==1]=MAX_LBL #  - Note: Take care lbl==1
# logistic transform (log[p/(1-p)]) to take care of boundry conditions
lbl_log <- log(lbl/(1-lbl))


#===== Create CV partitions ======
print('- create CV folds')
set.seed(seed_num)
folds<-createFolds(lbl, k=nfold, list=F)

ext=paste("_cv",nfold,"_maxRnd",ntrees,"_eStop",nstop,"_seed",seed_num,"_",grid_num, sep="")
# Write fold index to file
out_file=paste(out_loc,in_name,ext,"_foldIdx.txt",sep="")
write.table(folds,out_file,row.names=F,col.names=F,quote=F,append=F)

# Write grid to file
out_file=paste(out_loc,in_name,ext,"_idx",idx_s,"-",idx_e,".err",sep="")
header=paste("id","best_itr_mu", "best_itr_sd", 
             "tst_rmse_mu", "tst_rmse_sd", "trn_rmse_mu", "trn_rmse_sd", 
             "tst_pcor_mu", "tst_pcor_sd", "trn_pcor_mu", "trn_pcor_sd", 
             "tst_scor_mu", "tst_scor_sd", "trn_scor_mu", "trn_scor_sd", sep="\t")
write.table(header,out_file,row.names=F,col.names=F,quote=F,append=TRUE)

# ========== XGBoost grid search ==========
print('- cv grid search')
for (i in idx_s:idx_e){
  # Grid search, find best combo
  param <- list(max.depth        = xgb_grid$max_depth[i], 
                nround           = xgb_grid$nrounds[i], 
                eta              = xgb_grid$eta[i], 
                min_child_weight = xgb_grid$min_child_weight[i], 
                gamma            = xgb_grid$gamma[i], 
                subsample        = xgb_grid$subsample[i], 
                colsample_bytree = xgb_grid$colsample_bytree[i],
                verbose          = 0, 
                em1              = "rmse", 
                objective        = 'reg:linear')
  
  print(paste("---- xgb.cv, grid=", toString(i),"----",  sep="") )
  tstErr_all  <- matrix(0, 1, nfold) # init vector of zeros
  trnErr_all  <- matrix(0, 1, nfold)
  tstPcor_all <- matrix(0, 1, nfold)
  trnPcor_all <- matrix(0, 1, nfold)
  tstScor_all <- matrix(0, 1, nfold)
  trnScor_all <- matrix(0, 1, nfold)
  idx_all     <- matrix(0, 1, nfold)
  res_err <- NULL
  
  for (f in 1:nfold){
    # ========== Read current CV data ==========  
    dat_trn <- data[!folds==f,]       # Sample X Gene
    lbl_trn <- lbl[!folds==f]         # Purity value [0, 1]
    lbl_log_trn <- lbl_log[!folds==f] # Logist transformed purity value [-inf, +inf]
    dtrain  <- xgb.DMatrix(data=dat_trn, label=lbl_log_trn)
    
    dat_tst <- data[folds==f,]       # Sample X Gene
    lbl_tst <- lbl[folds==f]         # Purity value [0, 1]
    lbl_log_tst <- lbl_log[folds==f] # Logist transformed purity value [-inf, +inf]
    dtest   <- xgb.DMatrix(data=dat_tst, label=lbl_log_tst)
    
    watchlist <- list(test=dtest, train=dtrain)
    
    # ========== Train xgboost =========
    set.seed(seed_num)
    bst <- xgb.train(data      = dtrain,
                     watchlist = watchlist,
                     params    = param,
                     nround    = xgb_grid$nrounds,
                     early_stopping_rounds=nstop,
                     nthread   = nthread,
                     verbose   = 0)
    
    # Get training prediction based on current number of trees
    ptrn_log <- predict(bst, dtrain)
    ptst_log <- predict(bst, dtest)
    
    # Inverse logit transform (exp(x)/(1+exp(x)))
    ptrn <- exp(ptrn_log)/(1+exp(ptrn_log))
    ptst <- exp(ptst_log)/(1+exp(ptst_log))
    
    idx_all[f]    <- bst$best_iteration
    
    # Get RMSE
    tstErr_all[f] <- RMSE(ptst, lbl_tst)
    trnErr_all[f] <- RMSE(ptrn, lbl_trn)
    
    
    # Calculate Pearson correlation
    tstPcor_all[f] <- cor(ptst, lbl_tst)
    trnPcor_all[f] <- cor(ptrn, lbl_trn)
    
    # Calculate Spearman correlation
    tstScor_all[f] <- cor(ptst, lbl_tst, method = 'spearman')
    trnScor_all[f] <- cor(ptrn, lbl_trn, method = 'spearman')
    
    
  }#end-for each fold
  
  res_err <- t( c(i, mean(idx_all), sd(idx_all), 
                  mean(tstErr_all), sd(tstErr_all), mean(trnErr_all), sd(trnErr_all), 
                  mean(tstPcor_all), sd(tstPcor_all), mean(trnPcor_all), sd(trnPcor_all),
                  mean(tstScor_all), sd(tstScor_all), mean(trnScor_all), sd(trnScor_all)))
  write.table(format(res_err, digits=6, scientific=F), out_file, sep="\t", row.names=F, col.names=F, quote=F, append=TRUE)
  
}#end-for each grid search


print('- done')





