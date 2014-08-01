#!/usr/local/bin/bash

/gpfs/main/sys/shared/psfu/local/projects/matlab/R2013b/bin/matlab -nodisplay -nosplash -nodesktop -r "addpath '/home/amm4/git/TDRL/Human Test/Data';AnalyzeData('/home/amm4/git/TDRL/Human Test/Data/Analysis/Real Data v2/Take 2/data_raw.mat','/home/amm4/git/TDRL/Human Test/Data/Analysis/Real Data v2/Take 2/ArApBrBpSE',0,$SGE_TASK_ID);exit;"
