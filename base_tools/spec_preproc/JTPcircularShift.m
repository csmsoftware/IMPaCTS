% [ppm, spectra] = JTPcircularShift(ppm, spectra, amount)
%
% Align nmr spectra by moving points from one end of the spectra to the
% other.
%
% Arguments:
% spectra           Vector of a single 1D NMR spectra.
% ppm               A vector labelling the ppm value of each point in 
%                   'spectra'.
% amount            Number of points to shift.
%
% Return Values:
% ppm               The shifted ppm vector.
% spectra           The shifted spectra.
% 
% Last Revision 8/12/2007
% (c) 2007 Jake Thomas Midwinter Pearce

function spectra = JTPcircularShift(spectra, amount)


if(amount < 0)
    % Move from left of spectra to right
    shift = spectra(1:abs(amount));
    spectra(1:abs(amount)) = [];
    spectra = [spectra shift];
      
elseif(amount > 0)
    % Move from right of spectra to left
    amount2 = length(spectra) - amount;
    shift = spectra(amount2:length(spectra));
    spectra(amount2:length(spectra)) = [];
    spectra = [shift spectra];

else
    % Do nothing.
end

end