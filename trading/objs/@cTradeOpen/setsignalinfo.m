function [] = setsignalinfo(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name',[],@ischar);
    p.addParameter('ExtraInfo',[],@isstruct);
    p.parse(varargin{:});
    name = p.Results.Name;
    info = p.Results.ExtraInfo;
    
    if strcmpi(name,'WilliamsR')
        signalinfo = cWilliamsRInfo;
        try
            signalinfo.frequency_ = info.frequency;
        catch
            signalinfo.frequency_ = '';
        end
        %
        try
            signalinfo.highesthigh_ = info.highesthigh;
        catch
            signalinfo.highesthigh_ = [];
        end
        %
        try
            signalinfo.lowestlow_ = info.lowestlow;
        catch
            signalinfo.lowestlow_ = [];
        end
        %
        try
            signalinfo.lengthofperiod_ = info.lengthofperiod;
        catch
            signalinfo.lengthofperiod_ = [];
        end
        obj.opensignal_ = signalinfo;
        return
    end
    
    error('cTradeOpen:setsignalinfo:%s not implemented',name);
    
end