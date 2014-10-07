# MoralTests.R
# Commands for testing moral stuff from 2-step task
# Adam Morris, 8/1/2014

# Get data
#predictors = read.csv(paste(path,"/Predictors.csv",sep=""));
#dvs = read.csv(paste(path,"/DVs.csv",sep=""));

path = "C:\\Personal\\School\\Brown\\Psychology\\TDRL Project\\Code\\Daw_Moral\\Data4\\Take2";
setwd(path);
predictors = read.csv("Predictors.csv");
dvs = read.csv("DVs.csv");

# Create uncommon model & get slopes
predictors_uncommon <- predictors[(predictors$Common==-1),]
model_uncommon <- glmer(Stay~Reinf+(1+Reinf|Subj),family=binomial,data=predictors_uncommon);
model_uncommon_coef <- coef(model_uncommon);
model_uncommon_slopes <- model_uncommon_coef$Subj$Reinf;

# Create all model & get slopes
model_all <- glmer(Stay~Reinf*Common+(1+Reinf*Common|Subj),family=binomial,data=predictors);
model_all_coef = coef(model_all);
model_all_MFslopes = model_all_coef$Subj$Reinf;
model_all_MBslopes = model_all_coef$Subj$"Reinf:Common";

# WITH RP
model_uncommon_rp <- glmer(Stay~Reinf*RP+(1+Reinf*RP|Subj),family=binomial,data=predictors_uncommon);
model_uncommon_coef <- coef(model_uncommon);
model_uncommon_slopes <- model_uncommon_coef$Subj$Reinf;

# Create all model
model_all_rp <- glmer(Stay~Reinf*Common*RP+(1+Reinf*Common*RP|Subj),family=binomial,data=predictors,control=glmerControl(optimizer="bobyqa"));
model_all_rp_coef = coef(model_all_rp);
model_all_MFslopes_P = model_all_rp_coef$Subj$Reinf;
model_all_MFslopes_R = model_all_rp_coef$Subj$"Reinf:RP"+model_all_MFslopes_P;
model_all_MBslopes_P = model_all_rp_coef$Subj$"Reinf:Common";
model_all_MBslopes_R = model_all_rp_coef$Subj$"Reinf:Common:RP"+model_all_MBslopes_P;

# Simple model
model_all_rp_simple <- glmer(Stay~Reinf+Reinf:Common+Reinf:RP+Reinf:Common:RP+(1+Reinf+Reinf:Common+Reinf:RP+Reinf:Common:RP|Subj),family=binomial,data=predictors);
model_all_rp_coef_simple = coef(model_all_rp);
model_all_MFslopes_R_simple = model_all_rp_coef_simple$Subj$"Reinf:RP";
model_all_MFslopes_P_simple = model_all_rp_coef_simple$Subj$Reinf;
model_all_MBslopes_R_simple = model_all_rp_coef_simple$Subj$"Reinf:Common:RP";
model_all_MBslopes_P_simple = model_all_rp_coef_simple$Subj$"Reinf:Common";

# Tosslist?
threshold = .25;
tosslist = (model_all_MBslopes_R < quantile(model_all_MBslopes_R,threshold,type=1)) & (model_all_MFslopes_P < quantile(model_all_MFslopes_P,threshold,type=1)) & (model_all_MFslopes_R < quantile(model_all_MFslopes_R,threshold,type=1));

dv_tosslist = matrix(TRUE,288,1);
temp = c(83,123,180,202,212);
dv_tosslist[temp] = FALSE;

moral_test = glm(dvs$Moral[dv_tosslist]~model_all_MFslopes_R+model_all_MFslopes_P);
