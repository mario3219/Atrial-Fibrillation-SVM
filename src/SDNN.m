classdef SDNN
    methods(Static)
    % Class start

    function score = func(rr,windowsize,i)
         score = std(rr(i:i+windowsize));
    end

    % Class end
    end
end