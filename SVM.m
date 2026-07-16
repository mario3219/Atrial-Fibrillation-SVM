clc,clear

% Paths and conditions

% path to data
addpath('AF_RR_intervals/')
% path to source code
addpath('src/')

%% Feature selection

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_4.mat'};
validationdata = 'afdb_7.mat';

windowsize = 30;
stepsize = 30;
features = ["SSampEn","RMSSD","Poincare","pNN50","SDNN"];
filter = 1;
points = 7;
filterthreshold = 1.2;
binsize=0.04;

modelling.featureSelection(trainingdata,validationdata,windowsize,stepsize,filter,points,filterthreshold,binsize,features);

%% Gridsearch

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_4.mat','afdb_5.mat','afdb_6.mat','afdb_7.mat'};

windowsizes = 25:1:35;
stepsizes = 30;
features = ["SSampEn","RMSSD","Poincare","pNN50","SDNN"];
filters = 1;
points = 7;
filterthresholds = 1:0.1:1.5;
binsizes= 0.04;
k = 5;

[a,b,d,e,f,g,bestf1] = modelling.gridSearch(trainingdata,windowsizes,stepsizes,features,filters,points,filterthresholds,binsizes,k);
fprintf("Windowsize: " + a + "\n" + "Stepsize: " + b + "\n" + "Points: " + e + "\n" + "Median Filter threshold: " + f + "\n" + "Bin size: " + g + "\n" + "Best F1: " + bestf1 + "\n");

%% SVM

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_4.mat'};
validationdata = 'afdb_7.mat';

windowsize = 30;
stepsize = 30;
features = ["RMSSD","pNN50","SSampEn","SDNN"];
filter_train = 1;
filter_predict = 1;
points = 7;
filterthreshold = 1.2;
binsize=0.04;

model = modelling.SVMtrain(trainingdata,windowsize,stepsize,features,filter_train,points,filterthreshold,binsize);
predictions = modelling.SVMpredict(model,validationdata,windowsize,stepsize,features,binsize,filter_predict,points,filterthreshold);

inspect.compare(validationdata,predictions,windowsize,stepsize,points,filterthreshold);
