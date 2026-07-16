classdef votingdetector
    methods(Static)
        function thresholds = train(trainingdata,windowsize,stepsize,features,binsize,filter,points,filterthreshold)
             thresholds = zeros(5,1); % Length of vector equal to amount of implemented features
             for f = 1:length(features)
                        current_feature = "";
                        feature_name = features{f};
                        switch feature_name
                            case "RMSSD"
                                current_feature = "RMSSD";
                                thresholds(1) = modelling.train(trainingdata,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold);
                            case "SSampEn"
                                current_feature = "SSampEn";
                                thresholds(2) = modelling.train(trainingdata,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold);
                            case "Poincare"
                                current_feature = "Poincare";
                                thresholds(3) = modelling.train(trainingdata,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold);
                            case "pNN50"
                                current_feature = "pNN50";
                                thresholds(4) = modelling.train(trainingdata,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold);
                            case "SDNN"
                                current_feature = "SDNN";
                                thresholds(5) = modelling.train(trainingdata,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold);
                        end
              end
        end

        function predictions = predict(data,windowsize,stepsize,features,binsize,filter,points,filterthreshold,thresholds)
             for f = 1:length(features)
                        current_feature = "";
                        feature_name = features{f};
                        switch feature_name
                            case "RMSSD"
                                current_feature = "RMSSD";
                                threshold = thresholds(1);
                                predictions1 = modelling.predict(data,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold,threshold);
                                size = length(predictions1);
                            case "SSampEn"
                                current_feature = "SSampEn";
                                threshold = thresholds(2);
                                predictions2 = modelling.predict(data,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold,threshold);
                                size = length(predictions2);
                            case "Poincare"
                                current_feature = "Poincare";
                                threshold = thresholds(3);
                                predictions3 = modelling.predict(data,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold,threshold);
                                size = length(predictions3);
                            case "pNN50"
                                current_feature = "pNN50";
                                threshold = thresholds(4);
                                predictions4 = modelling.predict(data,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold,threshold);
                                size = length(predictions4);
                            case "SDNN"
                                current_feature = "SDNN";
                                threshold = thresholds(5);
                                predictions5 = modelling.predict(data,windowsize,stepsize,current_feature,binsize,filter,points,filterthreshold,threshold);
                                size = length(predictions5);
                        end
             end
             predictions = zeros(size,1);
             for k = 1:size
                positive = 0;
                negative = 0;
                for f = 1:length(features)
                    feature_name = features{f};
                    switch feature_name
                        case "RMSSD"
                            if predictions1(k,2) == 1
                                positive = positive + 1;
                            else
                                negative = negative + 1;
                            end
                        case "SSampEn"
                            if predictions2(k,2) == 1
                                positive = positive + 1;
                            else
                                negative = negative + 1;
                            end
                        case "Poincare"
                            if predictions3(k,2) == 1
                                positive = positive + 1;
                            else
                                negative = negative + 1;
                            end
                        case "pNN50"
                            if predictions4(k,2) == 1
                                positive = positive + 1;
                            else
                                negative = negative + 1;
                            end
                        case "SDNN"
                            if predictions5(k,2) == 1
                                positive = positive + 1;
                            else
                                negative = negative + 1;
                            end
                    end
                end
                if positive > negative
                    predictions(k) = 1;
                else
                    predictions(k) = 0;
                end
             end
        end

        function best_combo = featureSelection(trainingdata,validationdata,windowsize,stepsize,filter,points,filterthreshold,binsize,features)
            n = numel(features);
            all_combinations = {};
            
            for k = 1:n
                combs = nchoosek(1:n, k);
                for i = 1:size(combs,1)
                    all_combinations{end+1} = features(combs(i,:));
                end
            end
            
            best_combo = "RMSSD";
            best_f1 = 0;
            total_iterations = length(all_combinations);
            iteration = 1;
            for comb = all_combinations
                fprintf("Progress: " + iteration + "/" + total_iterations + "\n");
                features = comb{1};
                thresholds = votingdetector.train(trainingdata,windowsize,stepsize,features,binsize,filter,points,filterthreshold);
                predictions = votingdetector.predict(validationdata,windowsize,stepsize,features,binsize,filter,points,filterthreshold,thresholds);
                labels = inspect.getlabels(validationdata,windowsize,stepsize);
                f1 = inspect.f1score(labels, predictions);
                if f1 > best_f1
                    best_f1 = f1;
                    best_combo = features;
                    fprintf("New best F1: " + f1 + "\n");
                end
                iteration = iteration + 1;
            end
            fprintf("Best features:");
            disp(best_combo)    
        end

        function [besta, bestb, bestd, beste, bestf, bestg, bestf1] = gridSearch(trainingdata,validationdata,windowsizes, stepsizes, features, filter, points, filterthresholds, binsizes)
        
            total_iterations = length(windowsizes) * length(stepsizes) * length(filter) * length(points) * length(filterthresholds) * length(binsizes);
        
            % Preallocate
            scores = zeros(total_iterations, 7); % [a, b, d, e, f, g, f1]
        
            % Generate all combinations
            idx = 1;
            combinations = zeros(total_iterations, 6); % [a, b, d, e, f, g]
            for a = windowsizes
                for b = stepsizes
                    for d = filter
                        for e = points
                            for f = filterthresholds
                                for g = binsizes
                                    combinations(idx, :) = [a, b, d, e, f, g];
                                    idx = idx + 1;
                                end
                            end
                        end
                    end
                end
            end
        
            % Start parallel pool if needed
            if isempty(gcp('nocreate'))
                parpool;
            end
        
            % Create DataQueue and progress tracker
            D = parallel.pool.DataQueue;
            p = 0; % counter for progress
            afterEach(D, @(~) modelling.updateProgress(total_iterations, @() p + 1, @(v) assignin('base', 'p', v)));
        
            % Initialize p in base workspace
            assignin('base', 'p', 0);
        
            % Parallel loop
            parfor i = 1:total_iterations
                a = combinations(i, 1);
                b = combinations(i, 2);
                d = combinations(i, 3);
                e = combinations(i, 4);
                f = combinations(i, 5);
                g = combinations(i, 6);
                
                thresholds = votingdetector.train(trainingdata,a,b,features,g,filter,e,f);
                predictions = votingdetector.predict(validationdata,a,b,features,g,filter,e,f,thresholds);
                labels = inspect.getlabels(validationdata,a,b);
                f1 = inspect.f1score(labels, predictions);
        
                scores(i, :) = [a, b, d, e, f, g, f1];
        
                % Tell DataQueue that one iteration finished
                send(D, i);
            end
        
            % Find best
            [~, best_idx] = max(scores(:, 7));
            best = scores(best_idx, :);
        
            besta = best(1);
            bestb = best(2);
            bestd = best(3);
            beste = best(4);
            bestf = best(5);
            bestg = best(6);
            bestf1 = best(7);
        end
        
        function updateProgress(total, getValFunc, setValFunc)
            p = evalin('base', 'p');
            p = p + 1;
            fprintf('Progress: %d/%d (%.2f%%)\n', p, total, (p/total)*100);
            setValFunc(p);
        end

    end
end