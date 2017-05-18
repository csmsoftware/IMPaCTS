classdef csm_progress_bar
%CSM_PROGRESS_BAR - Progress Bar tool.
%
% Usage:
%
%	n = 300;
%	progBar = csm_progress_bar( n );
%	for i = 1 : length( n )
%		progBar.update( i );
%	end
%
% Arguments:
%
%	n : (1*1) Number of total iterations.
%
% Methods:
%
%	csm_object_converter.update( i ) : Update the progress bar.
%
% Description:
%	
%	Progress bar for usage in applications.
%
%	Based on DSprogressBar but new version.
%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016
	
	
	properties
		
		iteration_percentage;
		last_percentile_written;
		
	end
	
	methods
		
		function [obj] = csm_progress_bar( n )
                        
            % Allows creation of empty objects for cloning
            if nargin == 0
                return
            end
            
            obj.last_percentile_written = 0;
			
			obj.iteration_percentage = 100 / n;
			
			obj = printStart( obj );
			
		end
		
		function [obj] = printStart( obj )
			
			fprintf( 'Running ' );
			
		end
		
		function [obj] = update( obj, i )
			
			% Calculate current percentile
			new_percentile = round( i * obj.iteration_percentage );
			
			if new_percentile >= obj.last_percentile_written
				
				percentile_to_write = obj.last_percentile_written + 1;
				
				% Add potential missing percentiles.
				while( percentile_to_write <= new_percentile )
					
					% End
					if percentile_to_write == 100
						
						printEnd( obj );
						
						break;
						
					end
					
					% At every 10 add a '+'
					if( mod( percentile_to_write, 10 ) == 0 )
					
						fprintf( '+' );

					else
						
						fprintf( '.' );
					
					end
					
					percentile_to_write = percentile_to_write + 1;
					
				end
				
				obj.last_percentile_written = new_percentile;
				
			end	
			
		end
		
		function [obj] = printEnd( obj )
			
			fprintf( ' Complete! \n' );
			
		end	
		
	end
	
end

