classdef SSampEn
    methods(Static)
    % Class start
    function ssampen = func(rr_intervals, window_size, start_idx)
        % Calculates Simplified Sample Entropy (SSampEn) for a window of RR intervals
        % Inputs:
        %   rr_intervals - full array of RR intervals in ms
        %   window_size - number of RR intervals to analyze
        %   start_idx - starting index of the window
        %
        % Output:
        %   ssampen - Simplified Sample Entropy value
        
        % Extract the window
        window_rr = rr_intervals(start_idx:start_idx+window_size-1);
        N = length(window_rr);
        
        % Set parameters
        m = 1; % Subsequence length (fixed for SSampEn)
        r = 30; % Initial tolerance in ms (from research papers)
        
        % Calculate mean RR interval (excluding possible ectopic beats)
        mean_rr = mean(window_rr);
        
        % Adjust r until we find matches (as per research papers)
        while true
            % Calculate probability of matches (B(m=1,r))
            matches = 0;
            total_pairs = 0;
            
            for i = 1:N-1
                for j = i+1:N
                    if abs(window_rr(i) - window_rr(j)) <= r
                        matches = matches + 1;
                    end
                    total_pairs = total_pairs + 1;
                end
            end
            
            B = matches / total_pairs;
            
            % If we found matches or r is too large, break
            if matches > 0 || r > 100 % 100ms upper limit
                break;
            end
            
            % Increment r by 5ms (from research papers)
            r = r + 5;
        end
        
        % Calculate Simplified Sample Entropy (SSampEn)
        ssampen = B / mean_rr;
        
        % Handle case where no matches were found
        if isnan(ssampen) || isinf(ssampen)
            ssampen = 0;
        end
    end
    end
end