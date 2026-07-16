classdef pNN50
    methods(Static)
    % Class start

    function score = func(rr,windowsize,i)
        diffs = abs(diff(rr(i:i+windowsize)));
        score = sum(diffs > 0.05) / length(diffs);
    end

    % Class end
    end
end