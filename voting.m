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

votingdetector.featureSelection(trainingdata,validationdata,windowsize,stepsize,filter,points,filterthreshold,binsize,features)

%% Gridsearch

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_4.mat'};
validationdata = 'afdb_7.mat';

windowsizes = 25;
stepsizes = 10:10:50;
features = ["SSampEn","pNN50","RMSSD"];
filters = 1;
points = 1:2:10;
filterthresholds = 0.8:0.1:1.2;
binsizes= 0.01:0.01:0.07;

[a,b,d,e,f,g,bestf1] = votingdetector.gridSearch(trainingdata,validationdata,windowsizes,stepsizes,features,filters,points,filterthresholds,binsizes);
fprintf("Windowsize: " + a + "\n" + "Stepsize: " + b + "\n" + "Points: " + e + "\n" + "Median Filter threshold: " + f + "\n" + "Bin size: " + g + "\n" + "Best F1: " + bestf1 + "\n");

%% Voting detector

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_6.mat'};
validationdata = 'afdb_4.mat';

windowsize = 30;
stepsize = 30;
features = ["SSampEn","pNN50","RMSSD"];
filter = 1;
points = 7;
filterthreshold = 1.2;
binsize=0.04;

thresholds = votingdetector.train(trainingdata,windowsize,stepsize,features,binsize,filter,points,filterthreshold);
predictions = votingdetector.predict(validationdata,windowsize,stepsize,features,binsize,filter,points,filterthreshold,thresholds);
inspect.compare(validationdata,predictions,windowsize,stepsize,points,filterthreshold);