#!/usr/local/bin/bash

/gpfs/main/sys/shared/psfu/local/projects/matlab/R2013b/bin/matlab -nodisplay -nosplash -nodesktop -r "addpath '/home/amm4/git/TDRL/Human Test/Data';AnalyzeData('/home/amm4/git/TDRL/Dawes 2-Step Task/Take3/ABSE/data_ABSE.mat',$SGE_TASK_ID);exit;"
