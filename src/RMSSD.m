% Simple threshold detector based only on using RMSSD

classdef RMSSD
    methods(Static)
    % Class start

    function score = func(rr,windowsize,i)
         deltarr = diff(rr(i:i+windowsize));
         score = sqrt(mean(deltarr.^2));
    end

    % Class end
    end
end