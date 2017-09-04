function [survprob] = smoothbarrier(s,barrierlvl,barriertype,varargin)
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('Spot',@isnumeric);
p.addRequired('BarrierLevel',@isnumeric);
p.addRequired('BarrierType',@ischar);
p.addParameter('BarrierShift',0,@isnumeric);
p.addParameter('Wedge',0,@isnumeric);
p.addParameter('Mode','linear',@ischar);
p.parse(s,barrierlvl,barriertype,varargin{:});

s = p.Results.Spot;
blvl = p.Results.BarrierLevel;
btype = p.Results.BarrierType;
%sanity check of barrier type
if ~(strcmpi(btype,'ui') || strcmpi(btype,'uo') ...
        || strcmpi(btype,'di') || strcmpi(btype,'do'))
    error('smoothbarrier:invalid barrier type')
end

shift = p.Results.BarrierShift;
wedge = p.Results.Wedge;
if wedge < 0
    error('smoothbarrier:invalid wedge input,it must be nonnegative')
end

mode = p.Results.Mode;
if ~(strcmpi(mode,'linear') || strcmpi(mode,'gaussian'))
    error('smoothbarrier:invalid mode input,it must either be linear or gaussian');
end
    
blvl = blvl + shift;
if wedge == 0
    %zero wedge is a digital barrier
    if strcmpi(btype,'ui')
        %upper-and-in barrier
        if s >= blvl
            survprob = 1.0;
        else
            survprob = 0.0;
        end
    elseif strcmpi(btype,'uo')
        %upper-and-out barrier
        if s >= blvl
            survprob = 0.0;
        else
            survprob = 1.0;
        end
    elseif strcmpi(btype,'di')
        %down-and-in barrier
        if s <= blvl
            survprob = 1.0;
        else
            survprob = 0.0;
        end
    else
        %down-and-out barrier
        if s <= blvl
            survprob = 0.0;
        else
            survprob = 1.0;
        end
    end 
else
    %non-zero wedge
    lower = blvl - 0.5*wedge;
    upper = blvl + 0.5*wedge;
    if strcmpi(mode,'linear')
        if s <= lower
            p = 0;
        elseif s >= upper
            p = 1;
        else
            p = interp1([lower,upper],[0,1],s,'linear');
        end
    else
        %todo
    end
    
    if strcmpi(btype,'ui')
        %upper-and-in barrier
        survprob = p;
    elseif strcmpi(btype,'uo')
        %upper-and-out barrier
        survprob = 1 - p;
    elseif strcmpi(btype,'di')
        %down-and-in barrier
        survprob = 1 - p;
    else
        %down-and-out barrier
        survprob = p;
    end   
end



    



end