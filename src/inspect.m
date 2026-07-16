% Class with functions to inspect and evaluate data

classdef inspect
    methods(Static)
    % Class start
        % Generates subplots of all variables in given dataset
        function plotdata(data)
            load(data)
            screenSize = get(0, 'ScreenSize');
            fig = figure('Units', 'pixels', 'Position', [screenSize(3)/4, screenSize(4)/4, 1000, 600]);
            subplot(4,1,1),plot(targetsRR),title('targetsRR'), ylim([0.5 1.5])
            subplot(4,1,2),plot(targetsQRS),title('targetsQRS'), ylim([0.5 1.5])
            subplot(4,1,3),plot(rr),title('rr')
            subplot(4,1,4),plot(qrs),title('qrs')
        end

        function poincare(data,start,stop,binsize)
            load(data)
            binstart = 0;
            binstop = 3;
            
            x = rr(start:stop);
            y = rr(start+1:stop+1);
            
            min_y = min(y);
            max_y = max(y);
            min_x = min(x);
            max_x = max(x);
            
            figure
            plot(x, y, '.', 'MarkerSize', 20);
            xlabel("rr(n)"),ylabel("rr(n+1)")
            hold on
            
            bins = binstart:binsize:binstop;
            
            for i = bins
	            plot([i,i],[binstart, binstop],'b--'),hold on;
	            plot([binstart, binstop],[i, i],'b--'),hold on;
            end
            
            xlim([min_x, max_x]);
            ylim([min_y,max_y]);
        end

        % Performance evaluation. Plots the validation rr sequence, on top
        % of the predicted labels and true labels, aswell as showing
        % computed F1 score
        function compare(validationdata,predictions,windowsize,stepsize,points,threshold)
            load(validationdata)
            rr = modelling.medianfilter(rr,points,threshold);
            labels = inspect.getlabels(validationdata,windowsize,stepsize);

            f1 = inspect.f1score(labels, predictions);

            figure
            subplot(3,1,1),plot(rr),title("rr");
            subplot(3,1,2),plot(targetsRR),ylim([0.5 1.5]),title("True label");
            subplot(3,1,3),plot(predictions),ylim([0.5 1.5]),title("Predicted label");
            txt = ['F1 score: ' num2str(f1) ''];
            text(length(predictions)/3,1.2,txt)
        end

        % Plots score distribution among the classes. A good distribution
        % is clear distinct separation between classes. An overlap
        % signifies a weak predictor that can't distinguish the classes
        function scoreDistribution(predictions)
            scores = predictions(:,1);
            labels = predictions(:,2);
            
            figure
            histogram(scores(labels == 0))
            hold on
            histogram(scores(labels == 1))
            legend('0','1')
            title('Score distributions')
        end

        function result = getheartrate(rr)
            result = 60./rr;
        end

        function TP = TP(labels,predictions)
            TP = 0;
            for i = 1:length(labels)
                if predictions(i) == 1 && predictions(i) == labels(i)
                    TP = TP + 1;
                end
            end
        end

        function TN = TN(labels,predictions)
            TN = 0;
            for i = 1:length(labels)
                if predictions(i) == 0 && predictions(i) == labels(i)
                    TN = TN + 1;
                end
            end
        end

        function FP = FP(labels,predictions)
            FP = 0;
            for i = 1:length(labels)
                if predictions(i) == 1 && predictions(i) ~= labels(i)
                    FP = FP + 1;
                end
            end
        end

        function FN = FN(labels,predictions)
            FN = 0;
            for i = 1:length(labels)
                if predictions(i) == 0 && predictions(i) ~= labels(i)
                    FN = FN + 1;
                end
            end
        end
        
        % true and predictions vectors has to be 1xN dimension
        function f1 = f1score(true, predictions)

            TP = inspect.TP(true,predictions);
            TN = inspect.TN(true,predictions);
            FP = inspect.FP(true,predictions);
            FN = inspect.FN(true,predictions);
        
            precision = TP / (TP + FP + eps);
            recall = TP / (TP + FN + eps);
        
            f1 = 2 * (precision * recall) / (precision + recall + eps);
        end

        % Extract labels from a dataset
        function labels = getlabels(data,windowsize,stepsize)
            load(data)
            total_segments = length(1:stepsize:(length(rr)-windowsize));
            
            % Validation labels vector
            labels = zeros(total_segments,1);
            index = 1;
            for i = 1:stepsize:(length(rr)-windowsize)
                % Extracts the most frequent label in the window
                label = mode(targetsRR(i:i+windowsize-1));
                labels(index) = label;
                index = index + 1;
            end
        end
        
    % Class end
    end
end