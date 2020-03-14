library(pls)
library(mvdalab)
library(dplyr)
library(haven)
library(rlist)

options(max.print=1000000)

rm(list = ls())

# load SPSS data set   
UJ <- read_sav("http://fizyka.umk.pl/~tpiotrowski/complexity/UJ_gf_complexity.csv")

# sex==1 males, sex==2 females
# for overall group (males+females), the following selections should be commented out

# for females, there are no outliers
UJ <- UJ[UJ$sex==2,]

# for males, few outliers are removed
# UJ <- UJ[UJ$outliers==0& UJ$sex==1,]

X_UJ_AUC <- as.matrix(UJ %>% select(contains("AUC")))
X_UJ_AVG <- as.matrix(UJ %>% select(contains("AvgEnt")))
X_UJ_MaxSlope <- as.matrix(UJ %>% select(contains("MaxSlope")))
X <- cbind(X_UJ_AUC,X_UJ_AVG,X_UJ_MaxSlope)

y <- UJ$gf_final

# cases used for training
PLSmodel <- list(y,X)
names(PLSmodel) <- list('dep','indep')

# maximum number of components for PLS models
max_comp=30

# PLSR model with CV to determine number of components
UJ_PLSR_CV <- plsr(dep ~ indep, ncomp = max_comp, data = PLSmodel, method = "simpls", validation = "LOO", jackknife = TRUE, scale = TRUE)

# selection criterion for number of components
# IN STUDY, SELECTED NCOMP WERE SET AS FOLLOWS:
# OVERALL SAMPLE -> NCOMP = 3 (LOCAL MINIMUM CRITERION)
# WOMEN -> NCOMP = 1 (RANDOMIZATION TEST CRITERION)
# MEN -> NCOMP = 8 (LOCAL MINIMUM CRITERION)
numberSignifComp <- selectNcomp(UJ_PLSR_CV, method = "randomization", alpha=0.05, nperm=10000, plot = TRUE)

# Jack-knife estimator of regression coefficients
# jack.test(UJ_PLSR_CV,ncomp=numberSignifComp)
# jack.test(UJ_PLSR_CV,ncomp=3)

# R-squared and RMSEP for CV model
# R2(UJ_PLSR_CV)
# RMSEP(UJ_PLSR_CV)

# fitted (fixed-effect) PLS model with preselected number of components
UJ_PLSR_NO_CV <- plsr(dep ~ indep, ncomp = max_comp, data = PLSmodel, method = "simpls", scale = TRUE)

# R-squared and RMSEP for fitted model
# R2(UJ_PLSR_NO_CV)
# RMSEP(UJ_PLSR_NO_CV)

# fitted (fixed-effect) PLS model using MVDALAB function allowing for bootstrapped confidence interval estimation 
UJ_PLSR_BOOT <- plsFit(dep ~ indep, scale = TRUE, data = PLSmodel, ncomp = 1, validation = "oob", boots = 10000)

# R-squared for fitted model - the same (up to 1e^{-5}) as R2(UJ_PLSR_NO_CV) above
R2s(UJ_PLSR_BOOT)

# bootstrapped confidence interval estimation
cfs_int <- coefficients.boots(UJ_PLSR_BOOT, ncomp = 1, conf = .95)

# all intervals
x <- cfs_int[[1]]
x

# significant regression coefficients obtained from bootstrapped confidence interval estimation with alpha=0.05
filter(x,x$"2.5%">0)
filter(x,x$"97.5%"<0)

