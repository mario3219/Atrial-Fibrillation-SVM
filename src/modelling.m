% This script involves functions related to modelling

classdef modelling
    methods(Static)
% Class start

        % Model training and prediction functions
        % These functions require threshold criterion based models
        % The training is performed by selecting threshold based on best
        % performing F1 score

        % Strategy: Calculate score for each training set, perform predictions
        % based on a certain threshold, and return the threshold value which
        % provided the best F1 score.

        function threshold = train(trainingdata,windowsize,stepsize,feature,binsize,filter,points,filterthreshold)

            % Calculate number of segments to label, also necessary to
            % initialize label matrix with appropriate size to prevent
            % resizing
            total_segments = 0;
            for i = 1:length(trainingdata)
                load(trainingdata{i})
                total_segments = total_segments + length(1:stepsize:(length(rr)-windowsize));
            end
            results = zeros(total_segments,2);
            
            % Start iterating through trainingdata
            index = 1;
            for k = 1:length(trainingdata)
                
                load(trainingdata{k})
                
                % Ectopic beats filter
                if filter == 1
                    rr = modelling.medianfilter(rr,points,filterthreshold);
                end
                
                % TRAINING: Calculate score values and store the corresponding label to
                % that window
                for i = 1:stepsize:(length(rr)-windowsize)

                    % If-statements depending on which parameters the user
                    % wishes to compute

                    % Criterions input start
                    if feature == "RMSSD"
                        score = RMSSD.func(rr,windowsize,i);
                    elseif feature == "SSampEn"
                        score = SSampEn.func(rr, windowsize, i);
		            elseif feature == "Poincare"
			            score = Poincare.func(rr,windowsize,i,binsize);
                    elseif feature == "pNN50"
                        score = pNN50.func(rr,windowsize,i);
                    elseif feature == "SDNN"
                        score = SDNN.func(rr,windowsize,i);
		            else
                        error("Unknown feature: %s", feature)
                    end
                    % Criterion inputs end
                    
                    % Get true labels for that window
                    label = mode(targetsRR(i:i+windowsize));
                    results(index,:) = [score, label];
                    index = index + 1;
                end
            end

            % Separate scores and labels from matrix
            scores = results(:,1);
            labels = results(:,2);

            % Create threshold test vector
            thresholds = linspace(min(scores), max(scores),1000);

            % Find the threshold which provides the best F1 score
            bestf1 = 0;
            threshold = 0;
            for t = thresholds
                predictions = scores > t;
                f1 = inspect.f1score(labels, predictions);
                    
                if f1 > bestf1
                    bestf1 = f1;
                    threshold = t;
                end
            end

        end

        function result = predict(data,windowsize,stepsize,feature,binsize,filter,points,filterthreshold,threshold)
            load(data);

            % Ectopic beats filter
            if filter == 1
                rr = modelling.medianfilter(rr,points,filterthreshold);
            end

            total_segments = length(1:stepsize:(length(rr)-windowsize));
            result = zeros(total_segments,2);
            index = 1;
            for i = 1:stepsize:(length(rr)-windowsize)
    
                % If statements depending on which criterion the user
                % wishes to compute

                % Criterions input start
                if feature == "RMSSD"
                    score = RMSSD.func(rr,windowsize,i);
                elseif feature == "SSampEn"
                    score = SSampEn.func(rr, windowsize, i);
		        elseif feature == "Poincare"
		            score = Poincare.func(rr,windowsize,i,binsize);
                elseif feature == "pNN50"
                        score = pNN50.func(rr,windowsize,i);
                elseif feature == "SDNN"
                        score = SDNN.func(rr,windowsize,i);
                else
                    error("Unknown feature: %s", feature)
                end
                % Criterions input end
    
                % If score passes the threshold, it is labelled as 1
                if score > threshold
                    result(index,:) = [score, 1];
                else
                    result(index,:) = [score, 0];
                end
                index = index + 1;
            end
        end

        function rr = medianfilter(rr,points,threshold)
            for i = 1:points:(length(rr)-points)
                median = rr(i+round(points/2));
                for k = i:1:i+points
                    if rr(k)/median >= 1+threshold || rr(k)/median <= 1-threshold
                        rr(k) = median;
                    end
                end
            end
        end

        function model = SVMtrain(trainingdata, windowsize, stepsize, features, filter, points, filterthreshold, binsize)
            total_segments = 0;
            for i = 1:length(trainingdata)
                load(trainingdata{i});
                total_segments = total_segments + length(1:stepsize:(length(rr) - windowsize));
            end
        
            results = zeros(total_segments, length(features) + 1); % +1 for label
        
            index = 1;
            for k = 1:length(trainingdata)
                load(trainingdata{k});
        
                % Ectopic beats filter
                if filter == 1
                    rr = modelling.medianfilter(rr, points, filterthreshold);
                end
        
                % Calculate scores + labels
                for i = 1:stepsize:(length(rr) - windowsize)
                    label = mode(targetsRR(i:i+windowsize));
        
                    for f = 1:length(features)
                        feature_name = features{f};
        
                        switch feature_name
                            case "RMSSD"
                                score = RMSSD.func(rr, windowsize, i);
                            case "SSampEn"
                                score = SSampEn.func(rr, windowsize, i);
                            case "Poincare"
                                score = Poincare.func(rr, windowsize, i, binsize);
                            case "pNN50"
                                score = pNN50.func(rr, windowsize, i);
                            case "SDNN"
                                score = SDNN.func(rr,windowsize,i);
                        end
                        results(index, f) = score;
                    end
        
                    % Store label in the last column
                    results(index, length(features) + 1) = label;
                    index = index + 1;
                end
            end
        
            % Remove rows where all features are zero
            %results(all(results == 0, 2), :) = [];
        
            % Separate features and labels
            X = results(:, 1:end-1); % Features
            Y = results(:, end);     % Labels
        
            % Train SVM
            model = fitcsvm(X, Y);
        end
    
        function predictions = SVMpredict(SVM, data, windowsize, stepsize, features, binsize,filter,points,filterthreshold)
        load(data);

        % Ectopic beats filter
        if filter == 1
            rr = modelling.medianfilter(rr,points,filterthreshold);
        end
    
        total_segments = length(1:stepsize:(length(rr) - windowsize));
        formatted_data = zeros(total_segments, length(features));
        index = 1;
    
        for i = 1:stepsize:(length(rr) - windowsize)
            for f = 1:length(features)
                feature_name = features{f};
    
                switch feature_name
                    case "RMSSD"
                        score = RMSSD.func(rr, windowsize, i);
                    case "SSampEn"
                        score = SSampEn.func(rr, windowsize, i);
                    case "Poincare"
                        score = Poincare.func(rr, windowsize, i, binsize);
                    case "pNN50"
                        score = pNN50.func(rr, windowsize, i);
                    case "SDNN"
                        score = SDNN.func(rr,windowsize,i);
                end
                formatted_data(index, f) = score;
            end
            index = index + 1;
        end
    
        % Remove rows where all features are zero
        %formatted_data(all(formatted_data == 0, 2), :) = [];
    
        % Predict
        predictions = predict(SVM, formatted_data);
    end

        function [besta, bestb, bestd, beste, bestf, bestg, bestf1] = gridSearch(trainingdata,windowsizes, stepsizes, features, filter, points, filterthresholds, binsizes, k)
        
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
        
                model = modelling.SVMkfoldtrain(trainingdata, a, b, features, d, e, f, g, k);
                predictions = kfoldPredict(model);
                labels = model.Y;
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
        
        function model = SVMkfoldtrain(trainingdata, windowsize, stepsize, features, filter, points, filterthreshold, binsize,kf)
        total_segments = 0;
        for i = 1:length(trainingdata)
            load(trainingdata{i});
            total_segments = total_segments + length(1:stepsize:(length(rr) - windowsize));
        end
    
        results = zeros(total_segments, length(features) + 1); % +1 for label
    
        index = 1;
        for k = 1:length(trainingdata)
            load(trainingdata{k});
    
            % Ectopic beats filter
            if filter == 1
                rr = modelling.medianfilter(rr, points, filterthreshold);
            end
    
            % Calculate scores + labels
            for i = 1:stepsize:(length(rr) - windowsize)
                label = mode(targetsRR(i:i+windowsize));
    
                for f = 1:length(features)
                    feature_name = features{f};
    
                    switch feature_name
                        case "RMSSD"
                            score = RMSSD.func(rr, windowsize, i);
                        case "SSampEn"
                            score = SSampEn.func(rr, windowsize, i);
                        case "Poincare"
                            score = Poincare.func(rr, windowsize, i, binsize);
                        case "pNN50"
                            score = pNN50.func(rr, windowsize, i);
                        case "SDNN"
                            score = SDNN.func(rr,windowsize,i);
                    end
                    results(index, f) = score;
                end
    
                % Store label in the last column
                results(index, length(features) + 1) = label;
                index = index + 1;
            end
        end
    
        % Remove rows where all features are zero
        results(all(results == 0, 2), :) = [];
    
        % Separate features and labels
        X = results(:, 1:end-1); % Features
        Y = results(:, end);     % Labels
    
        % Train SVM
        model = fitcsvm(X, Y, 'KFold',kf);
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
                model = modelling.SVMtrain(trainingdata,windowsize,stepsize,features,filter,points,filterthreshold,binsize);
                predictions = modelling.SVMpredict(model,validationdata,windowsize,stepsize,features,binsize,filter,points,filterthreshold);
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

% Class end
    end
end
