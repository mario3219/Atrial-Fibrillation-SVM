% Simple threshold detector based only on using RMSSD

classdef Poincare
    methods(Static)
    % Class start

    function score = func(rr,windowsize,i,binsize)
    start = i;
	stop = i+windowsize;
	binstart = 0;
	binstop = 3;
	
	if stop >= length(rr)-1
		stop = length(rr)-1;
	end

	x = rr(start:stop);
	y = rr(start+1:stop+1);

	bins = binstart:binsize:binstop;

	nonzero_bins = 0;
	for j = 1:length(bins)-1
	    for k = 1:length(bins)-1
		x_low = bins(j);
		x_high = bins(j+1);
		y_low = bins(k);
		y_high = bins(k+1);
		
		points_in_bin = (x >= x_low) & (x < x_high) & (y >= y_low) & (y < y_high);
		inside_sum = sum(points_in_bin);
		if inside_sum > 0
			nonzero_bins = nonzero_bins + 1;
		end
	    end
	end
	score = nonzero_bins;
    end

    % Class end
    end
end

