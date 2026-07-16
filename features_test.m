clc,clear

% Paths and conditions

% path to data
addpath('AF_RR_intervals/')
% path to source code
addpath('src/')

%% RMSSD

% Simple threshold detector based only on RMSSD
% Assume afdb_1 -> afdb_4 is used for training
% Strategy: Calculate RMSSD for each training set, find the best threshold
% that provides the best F1 score, then validate the result with validation
% data (afdb_5 -> afdb_7)

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_4.mat'};
validationdata = 'afdb_6.mat';

windowsize = 30;
stepsize = 30;
feature = "RMSSD";
filter_train = 1;
filter_predict = 1;
points = 10;
filterthreshold = 0.2;
binsize = 0;

% Train & predict
threshold = modelling.train(trainingdata,windowsize,stepsize,feature,binsize,filter_train,points,filterthreshold);
predictions = modelling.predict(validationdata,windowsize,stepsize,feature,binsize,filter_predict,points,filterthreshold,threshold);

% Performance evaluation
inspect.compare(validationdata,predictions(:,2),windowsize,stepsize,points,filterthreshold);
inspect.scoreDistribution(predictions)

%% SSampEn

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_4.mat'};
validationdata = 'afdb_7.mat';

windowsize = 30;
stepsize = 30;
feature = "SSampEn";
filter_train = 1;
filter_predict = 1;
points = 10;
filterthreshold = 0.2;

threshold = modelling.train(trainingdata,windowsize,stepsize,feature,binsize,filter_train,points,filterthreshold);
predictions = modelling.predict(validationdata,windowsize,stepsize,feature,binsize,filter_predict,points,filterthreshold,threshold);

inspect.compare(validationdata,predictions,windowsize,stepsize,points,filterthreshold);
inspect.scoreDistribution(predictions)

%% Poincare

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_4.mat'};
validationdata = 'afdb_7.mat';

windowsize = 30;
stepsize = 30;
feature = "Poincare";
filter_train = 1;
filter_predict = 1;
points = 10;
filterthreshold = 0.2;
binsize = 0.025;

threshold = modelling.train(trainingdata,windowsize,stepsize,feature,binsize,filter_train,points,filterthreshold);
predictions = modelling.predict(validationdata,windowsize,stepsize,feature,binsize,filter_predict,points,filterthreshold,threshold);

inspect.compare(validationdata,predictions,windowsize,stepsize,points,filterthreshold);
inspect.scoreDistribution(predictions)

%% pNN50

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_4.mat'};
validationdata = 'afdb_7.mat';

windowsize = 30;
stepsize = 30;
feature = "pNN50";
filter_train = 1;
filter_predict = 1;
points = 10;
filterthreshold = 0.2;
binsize = 0;

% Train & predict
threshold = modelling.train(trainingdata,windowsize,stepsize,feature,binsize,filter_train,points,filterthreshold);
predictions = modelling.predict(validationdata,windowsize,stepsize,feature,binsize,filter_predict,points,filterthreshold,threshold);

% Performance evaluation
inspect.compare(validationdata,predictions,windowsize,stepsize,points,filterthreshold);
inspect.scoreDistribution(predictions)

%% SDNN

trainingdata = {'afdb_1.mat','afdb_2.mat','afdb_3.mat','afdb_4.mat'};
validationdata = 'afdb_6.mat';

windowsize = 30;
stepsize = 30;
feature = "SDNN";
filter_train = 1;
filter_predict = 1;
points = 13;
filterthreshold = 0.65;
binsize = 0.04;

% Train & predict
threshold = modelling.train(trainingdata,windowsize,stepsize,feature,binsize,filter_train,points,filterthreshold);
predictions = modelling.predict(validationdata,windowsize,stepsize,feature,binsize,filter_predict,points,filterthreshold,threshold);

% Performance evaluation
inspect.compare(validationdata,predictions,windowsize,stepsize,points,filterthreshold);
inspect.scoreDistribution(predictions)