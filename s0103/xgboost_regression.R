#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# *************************************************************
# Build boosted regression tree ensemble using training data
# Predict testing samples using the ensemble
# 
# Note:
#   - Assume we have not testing labels
#
# yuanyuan.li@nih.gov
# created : 07-06-2018
# *************************************************************
options("expressions"=500000) #max no. nested iterations
require(caret)
require(xgboost)
require(MLmetrics)
require(data.table)
require(vcd)
require(e1071)



in_loc  <- args[1]
in_name <- args[2]
out_loc <- args[3]

nfold      = as.numeric(args[4])    # k-fold cv
nrepeats   = as.numeric(args[5])    # repeated cross validation
ntrees     = as.numeric(args[6])    # max num of boosted trees
nstop      = as.numeric(args[7])    # early stopping criteria

MAX_LBL    = 0.9975     # Make sure never == 1

# ===== XGBoost train with given parameter  ====
param <- list(
         max_depth        = as.numeric(args[8]),
         min_child_weight = as.numeric(args[9]), 
         eta              = as.numeric(args[10]),  
         gamma            = 0,    
         colsample_bytree = as.numeric(args[11]),     
         subsample        = as.numeric(args[12]), 
         verbose          = 0,
         em1              = "rmse",
         objective        = 'reg:linear'
)

seed_num   = as.numeric(args[13])    # starting seed number
nthreads   = as.numeric(args[14])    # number of threads to use

# ========== Read in data ==========
# Output name
ext_name <- paste(
       "_nrep",toString(nrepeats),
       "_cv",toString(nfold),
       "_nr",toString(ntrees),
       "_d",toString(param$max_depth),
       "_cw",toString(param$min_child_weight),
       "_eta",toString(param$eta),
       "_ga",toString(param$gamma),
       "_cs",toString(param$colsample_bytree),
       "_ss",toString(param$subsample),
       "_estop",toString(nstop),
       "_sd",toString(seed_num),
       sep="")


#===== Read in data ======
print('- read data')
# Read in the training expression data
infile  <- paste(in_loc, in_name, '_trn.value', sep="")
dat     <- read.table(infile, header=F, sep="\t")
dat     <- data.matrix(dat)   # Sample X Gene

# Read in the training label
infile  <- paste(in_loc, in_name, '_trn.label',  sep="")
label   <- read.table(infile, header=F, sep="\t")
lbl     <- label$V2 # Purity value [0, 1]
lbl[lbl==1]=MAX_LBL #  - Note: Take care lbl==1


filename <- paste(in_loc,in_name,"_trn.gene",sep="")
gene <- read.table(filename,sep="\n",header=F)  # Gene names
gene <- as.character(gene[,1])


# Read in the testing expression data
infile  <- paste(in_loc, in_name, '_tst.value', sep="")
dat_tst <- read.table(infile, header=F, sep="\t")
dat_tst <- data.matrix(dat_tst)   # Sample X Gene

# Put testing data into xgb matrix format
dtest  <- xgb.DMatrix(data=dat_tst)



#===== Transform data ======
print('- transformation')
# logistic transform (log[p/(1-p)])
lbl_log <- log(lbl/(1-lbl))



# Write performance of each repeat of each iteration to file
out_per=paste(out_loc,in_name,ext_name,"_trn_cv_performance.txt",sep="")
print(out_per)
header=paste("repeat","fold","cvErr","trnErr",
             "cvPcorr","trnPcorr","cvScorr","trnScorr",sep="\t")
write.table(header,out_per,row.names=F,col.names=F,quote=F,append=T)

#Write predictions to file 
out_ptrn=paste(out_loc,in_name,ext_name,"_all_trn_prediction.txt",sep="")
out_pcv=paste(out_loc,in_name,ext_name,"_all_cv_prediction.txt",sep="")
out_ptst=paste(out_loc,in_name,ext_name,"_all_tst_prediction.txt",sep="")

#===== XGBoost ensemble learning & predictions ======
print('- learning & predicting')
ptst_all <- NULL
# for each repeats, create CV partitions
for (r in 1:nrepeats){
  
   print(paste("---- xgboost model ", toString(r),"----",  sep="") )
  
   # use seed number of make sure partitions are different
   set.seed(seed_num+r)
   folds<-createFolds(lbl, k=nfold, list=F)

   # write fold index to file
   out_file=paste(out_loc,in_name,ext_name,"_fold.txt",sep="")
   write.table(t(folds),out_file,row.names=F,col.names=F,quote=F,append=T)

   # build model for each CV partition & predict test set data
   for (f in 1:nfold){

      # -------- prepare current CV data -----------
      dat_trn <- dat[!folds==f,]       # Sample X Gene
      lbl_trn <- lbl[!folds==f]         # Purity value [0, 1]
      lbl_log_trn <- lbl_log[!folds==f] # Logist transformed purity value [-inf, +inf]
      dtrain  <- xgb.DMatrix(data=dat_trn, label=lbl_log_trn)

      dat_cv <- dat[folds==f,]       # Sample X Gene
      lbl_cv <- lbl[folds==f]         # Purity value [0, 1]
      lbl_log_cv <- lbl_log[folds==f] # Logist transformed purity value [-inf, +inf]
      dcv   <- xgb.DMatrix(data=dat_cv, label=lbl_log_cv)

      # xgboost: use watchlist for monitoring the evaluation result on all data in the list 
      watchlist <- list(test=dcv, train=dtrain)

      set.seed(seed_num+r)   
      bst <- xgb.train(data      = dtrain,
                       watchlist = watchlist,
                       params    = param,
                       nround    = ntrees,
                       early_stopping_rounds=nstop,
                       nthread   = nthreads,
                       verbose   = 0)

       # Get training prediction based on current number of trees
       ptrn_log <- predict(bst, dtrain)
       ptst_log <- predict(bst, dtest)
       pcv_log  <- predict(bst, dcv)

       # Inverse logit transform (exp(x)/(1+exp(x)))
       ptrn <- exp(ptrn_log)/(1+exp(ptrn_log))
       ptst <- exp(ptst_log)/(1+exp(ptst_log))
       pcv  <- exp(pcv_log)/(1+exp(pcv_log))


       # Get RMSE
       trnErr <- RMSE(ptrn, lbl_trn)
       cvErr  <- RMSE(pcv,  lbl_cv)
       
       # Calculate Pearson correlation
       trnPcor <- cor(ptrn, lbl_trn)
       cvPcor  <- cor(pcv,  lbl_cv)

       # Calculate Spearman correlation
       trnScor <- cor(ptrn, lbl_trn, method = 'spearman')
       cvScor  <- cor(pcv,  lbl_cv, method = 'spearman')

       
       # Write performance to file
       res_err <- t( c(r, f, cvErr, trnErr, cvPcor, trnPcor, cvScor, trnScor))
       write.table(format(res_err, digits=6, scientific=F),out_per,sep="\t",row.names=F,col.names=F,quote=F,append=T)

       # Write predictions to file
       write.table(ptst,file=out_ptst,sep="\t",row.names=F,col.names=F,quote=F,append=T)
       write.table(cbind(ptrn, lbl_trn),file=out_ptrn,sep="\t",row.names=F,col.names=F,quote=F,append=T)
       write.table(cbind(pcv, lbl_cv),file=out_pcv,sep="\t",row.names=F,col.names=F,quote=F,append=T)
       
       # Get important features from the current model
       importance <- xgb.importance(feature_names=gene, model=bst)
       # write features to file 
       out_file <- paste(out_loc,'importantFeatures/',in_name,ext_name,"_rep",r,"_fld",f,"_feature.txt", sep="")
       write.table(importance, file=out_file, sep="\t", row.names=F, quote=F) 

       # combine test predictions together
       ptst_all <- rbind(ptst_all, ptst)

   }#end-for each CV
   
}#end-for all repeated cv



#===== Calculate final test set precition from all models' predictions ====
print('- get ensemble test predictions')
#  - by taking average of all predictions
ptst_pred = colMeans(ptst_all)

out_file <- paste(out_loc,in_name,ext_name,"_test_ensemble_prediction.txt", sep="")
write.table(data.frame(ptst_pred), file=out_file, sep="\t", col.names=F, row.names=F, quote=F) 



print('- done')














