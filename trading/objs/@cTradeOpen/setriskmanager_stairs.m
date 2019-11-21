function [] = setriskmanager_stairs(obj,varargin) 
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name',[],@ischar);
    p.addParameter('ExtraInfo',[],@isstruct);
    p.parse(varargin{:});
    name = p.Results.Name;
    info = p.Results.ExtraInfo;
    if ~strcmpi(name,'stairs')
        error('cTradeOpen:setriskmanager_stairs:internal error!!!')
    end
    
    riskmanager = cStairs;
    propnamelist = properties(riskmanager);
    
    for i = 1:size(propnamelist,1);
        if strcmpi(propnamelist{i},'name_')
            continue;
        elseif strcmpi(propnamelist{i},'trade_')
            riskmanager.trade_ = obj;
        else
            try
                val = info.(propnamelist{i});
                riskmanager.(propnamelist{i}) = val;
            catch
                %use default values
            end
        end
    end
        
    obj.riskmanager_ = riskmanager;
    
end