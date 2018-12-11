function [] = setriskmanager(obj,varargin)
%cTradeOpen
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
        try
            riskmanager.status_ = info.status;
        catch
            riskmanager.status_ = 'unset';
        end
        try
            riskmanager.pxtarget_ = info.pxtarget;
        catch
            riskmanager.pxtarget_ = -9.99;
        end
        try
            riskmanager.pxstoploss_ = info.pxstoploss;
        catch
            riskmanager.pxstoploss_ = -9.99;
        end
        try
            riskmanager.bandwidthmin_ = info.bandwidthmin;
        catch
            riskmanager.bandwidthmin_ = 0.3333;
        end
        try
            riskmanager.bandwidthmax_ = info.bandwidthmax;
        catch
            riskmanager.bandwidthmax_ = 0.5;
        end
        try
            riskmanager.bandstoploss_ = info.bandstoploss;
        catch
            riskmanager.bandstoploss_ = -9.99;
        end
        try
            riskmanager.bandtarget_ = info.bandtarget;
        catch
            riskmanager.bandtarget_ = -9.99;
        end
        
        if info.bandstoploss ~= -9.99 && info.bandtarget ~= -9.99
            riskmanager.setstoplossfromsignalinfo(obj.opensignal_);
            riskmanager.settargetfromsignalinfo(obj.opensignal_);
        end
        obj.riskmanager_ = riskmanager;
        
    elseif strcmpi(name,'standard')
        riskmanager = cStandard;
        riskmanager.trade_ = obj;
        try
            riskmanager.status_ = info.status;
        catch
            riskmanager.status_ = 'unset';
        end
        try
            riskmanager.pxtarget_ = info.pxtarget;
        catch
            riskmanager.pxtarget_ = -9.99;
        end
        try
            riskmanager.pxstoploss_ = info.pxstoploss;
        catch
            riskmanager.pxstoploss_ = -9.99;
        end
        obj.riskmanager_ = riskmanager;
    else
        error('cTradeOpen:setriskmanager:%s not supported',name);
    end
    
    
end