function [idxunwind,unwinddt] = unwindinfo(obj,varargin)
%bkcStraddle
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Limit',inf,@isnumeric);
    p.addParameter('Stop',-inf,@isnumeric);
    p.addParameter('DaysCut',[],@isnumeric);
    p.addParameter('Criterial','pv',@ischar);
    p.parse(varargin{:});
    upperbound = p.Results.Limit;
    lowerbound = p.Results.Stop;
    dayscut = p.Results.DaysCut;
    usedaycut = ~isempty(dayscut);
    criterial = p.Results.Criterial;

    if isempty(obj.pvs_)
        idxunwind = [];
        unwinddt = [];
        return
    end
    
    %note:criterial with 'delta ' is for synthetic straddle
    if strcmpi(criterial,'pv')
        rets = obj.pvs_/obj.pvs_(1);
    elseif strcmpi(criterial,'delta')
        rets = cumsum(obj.deltapnl_)/obj.pvs_(1)+1;
    else
        error('%s:unwindinfo:invalid criterial input!',class(obj));
    end
    
    idx1 = find(rets >= upperbound,1,'first');
    if isempty(idx1), idx1 = length(obj.pvs_);end
    
    idx2 = find(rets <= lowerbound,1,'first');
    if isempty(idx2), idx2 = length(obj.pvs_);end
    
    idx3 = length(obj.pvs_);
    if usedaycut, idx3 = dayscut;end
    
    idxunwind = min([idx1,idx2,idx3]);
    if isnan(rets(idxunwind))
        %the straddle is still live
%         idx4 = find(isnan(rets),1,'first');
%     
%         idx4 = idx4-1;
%         idxunwind = min(idxunwind,idx4);
        idxunwind = -1;
        unwinddt = NaN;
    else
        obj.status_(idxunwind:end) = 0;
        unwinddt = obj.tradedts_(idxunwind);
    end

    
    
            
end