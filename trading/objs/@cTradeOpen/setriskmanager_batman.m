function [] = setriskmanager_batman(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name',[],@ischar);
    p.addParameter('ExtraInfo',[],@isstruct);
    p.parse(varargin{:});
    name = p.Results.Name;
    info = p.Results.ExtraInfo;
    if ~strcmpi(name,'batman')
        error('cTradeOpen:setriskmanager_batman:internal error!!!')
    end
    
    riskmanager = cBatman;
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
    
    if info.bandstoploss_ ~= -9.99 && info.bandtarget_ ~= -9.99 && ...
            strcmpi( riskmanager.status_,'unset')
        riskmanager.setstoplossfromsignalinfo(obj.opensignal_);
        riskmanager.settargetfromsignalinfo(obj.opensignal_);
    end
        
    obj.riskmanager_ = riskmanager;
end