% function CJSquerySplot(X,Y,label)
% function to plot an X Y scatter plot with points labeled (datatip tool)
%
% REQUIRED INPUT ARGUMENTS
% X (1,nv)  = X scatter data 
% Y (1,nv)  = Y scatter data
% label (1,nv) = label for each point
%
% NOTE: if you close generated figures without first selecting datatip in
% the plot browser, for some reason the datatip functionality will fail,
% therefore for full functionality datatip must be selected THEN figure
% saved and closed
%
% CJS 071014 caroline.sands01@imperial.ac.uk

function CJSquerySplot(X,Y,label)

% 1. Some basic checks
if(size(X,2) > size(X,1));
    X = X';
end

if(size(Y,2) > size(Y,1));
    Y = Y';
end

if(size(label,2) > size(label,1));
    label = label';
end

% 2. Plot
figure; set(gcf,'Color',[1 1 1]); 
h = plot(X, Y ,'og','MarkerEdgeColor','k','MarkerSize',5);  
set(h,'UserData',{X Y label});

% 3. Add required datatips
dcm = datacursormode(gcf);
datacursormode on
set(dcm, 'updatefcn',@datatipCS)


function output_txt = datatipCS(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');

data = get(event_obj.Target,'UserData');

IX = data{1} == pos(1) & data{2} == pos(2);

tmp = data{3};
tmp = tmp(IX);
if(iscell(tmp));
    tmp = tmp{1,1};
    out = tmp;
else
    out = sprintf('feature: %.5g',tmp);
end
  
output_txt = out;  