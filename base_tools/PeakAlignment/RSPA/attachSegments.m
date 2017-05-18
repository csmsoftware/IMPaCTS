function [testSegmentsNew,refSegmentsNew]=...
    attachSegments(refSegments,testSegments);
% Concatenation of test and reference segments to their ensure one-to-one
% correspondence
% Algorithm
%    - For each reference segment within segment boundaries, i.e. between
%      initial and final positions, find all centre (middle) positions of test segments 
%      and merge those segments, if more than one centre position is found
%    - Apply the same procedure for each test segment
%    Input: refSegments
%           testSegments

testSegmentsNew=validateSegments(refSegments,testSegments);
refSegmentsNew=validateSegments(testSegmentsNew,refSegments);

return;
        
function segments=validateSegments(refSegments,testSegments)
% Combine segments 
ref_length=length(refSegments);
int_length=length(testSegments);

i_centre= get_central_pos(testSegments);
index=1;
concatination=[];

for i=1:ref_length
    left_bnd=refSegments(i).start;
    right_bnd=refSegments(i).end;
    [val,ind]=find(i_centre>left_bnd & i_centre<right_bnd);
    if length(ind)>1
        concatination(index).segments=ind;
        index=index+1;
    end
end

if index==1
    segments=testSegments;
else
    conc_index=1;
    seg_index=1;
    i=1;
    while i<=int_length
        if conc_index<index
            if concatination(conc_index).segments(1)==i
                indexes=concatination(conc_index).segments;
                segment=unite_segments(testSegments(indexes));
                segments(seg_index)=segment;
                i=concatination(conc_index).segments(end)+1;
                seg_index=seg_index+1;
                conc_index=conc_index+1;
                continue;
            end
        end
        segments(seg_index)=testSegments(i);
        i=i+1;
        seg_index=seg_index+1;
    end
end
return;

function i_centre=get_central_pos(segments);
% segments 
ilength=length(segments);
i_centre=[];
for i=1:ilength
    i_centre=[i_centre segments(i).centre];
end
return;

function segment=unite_segments(segments)
% concatination of segments
ilength=length(segments);
i_centre=[];
segment.start=segments(1).start;
segment.PeakLeftBoundary=[];
segment.PeakRightBoundary=[];
segment.Peaks=[];
for i=1:ilength
    segment.PeakLeftBoundary=...
        [segment.PeakLeftBoundary segments(i).PeakLeftBoundary];
    segment.PeakRightBoundary=...
        [segment.PeakRightBoundary segments(i).PeakRightBoundary];
    segment.Peaks=...
        [segment.Peaks segments(i).Peaks];
end
segment.end=segments(end).end;
segment.centre=ceil((segment.start+segment.end)./2);
return;