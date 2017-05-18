function f = progressBar(nMax)
%progressBar    Ascii progress bar.
%   progBar = progressBar(nSteps) creates a progress bar and returns a 
%   pointer to a function handle which can then be called to update it.
%
%   To update, call progBar(currentStep)
%
%   Example:
%      n = 5000; 
%      progBar = progressBar(n);
%      for tmp = 1:n
%        progBar(tmp); 
%      end
 
%   by David Szotten 2008
%   $Revision: 1.2 $  $Date: 2008/04/17 09:15:32 $

lastPercentileWritten = 0;

fprintf('| 0');
for tmp = 1:91
	fprintf(' ');
end
fprintf('100%% |\n');

f = @updateBar;
	function updateBar(nCurrent)
		
		%what percentile are we up to
		currentPercentile = round(100*nCurrent/nMax);

		%have we passed another percentile?
		if (currentPercentile > lastPercentileWritten )
			
			%we may have increased by several percentiles,
			%so keep writing until we catch up
			percentileToWrite = lastPercentileWritten + 1;
			while(percentileToWrite <= currentPercentile)

				%for every 10th, use a '+' instead
				if( mod(percentileToWrite,10)==0 )
					fprintf('+');
					
					%are we done?
					if percentileToWrite == 100
						fprintf('\n');
					end
				else
					fprintf('-');
				end
				percentileToWrite = percentileToWrite + 1;
			end
			
			%update status
			lastPercentileWritten = currentPercentile;
		end
	end

end
