function [] = setriskmanager(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name',[],@ischar);
    p.addParameter('ExtraInfo',[],@isstruct);
    
    p.parse(varargin{:});
    name = p.Results.Name;
    info = p.Results.ExtraInfo;
    
    if strcmpi(name,'batman')
        riskmanager = cBatman;
        riskmanager.trade_ = obj;
        if ~isempty(info)
            try
                obj.bandwidthmin_ = info.bandwidthmin;
            catch
            end
            %
            try
                obj.bandwidthmax_ = info.bandwidthmax;
            catch
            end
            %
            try
                obj.bandstoploss_ = info.bandstoploss;
            catch
            end
            %
            try
                obj.bandtarget_ = info.bandtarget;
            catch
            end
            %
        end
        riskmanager.setstoplossfromsignalinfo(obj.opensignal_);
        riskmanager.settargetfromsignalinfo(obj.opensignal_);
        obj.riskmanager_ = riskmanager;
        
    elseif strcmpi(name,'standard')
        riskmanager = cStandard;
        riskmanager.trade_ = obj;
        obj.riskmanager_ = riskmanager;
    else
        error('cTradeOpen:setriskmanager:%s not supported',name);
    end
    
    
end