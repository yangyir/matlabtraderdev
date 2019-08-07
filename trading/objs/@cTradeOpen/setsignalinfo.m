function [] = setsignalinfo(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name',[],@ischar);
    p.addParameter('ExtraInfo',[],@isstruct);
    p.parse(varargin{:});
    name = p.Results.Name;
    info = p.Results.ExtraInfo;
    
    if strcmpi(name,'manual')
%         signalinfo = cSignalInfo;
        signalinfo =  cManualInfo;
        try
            signalinfo.frequency_ = info.frequency;
        catch
            signalinfo.frequency_ = '';
        end
        try
            signalinfo.riskmanagername_ = info.riskmanagername;
        catch
            signalinfo.riskmanagername_ = 'standard';
        end
        try
            signalinfo.pxtarget_ = info.pxtarget;
        catch
            signalinfo.pxtarget_ = -9.99;
        end
        try
            signalinfo.pxstoploss_ = info.pxstoploss;
        catch
            signalinfo.pxstoploss_ = -9.99;
        end
        obj.opensignal_ = signalinfo;
        return
    elseif strcmpi(name,'WilliamsR')
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
        %
        try
            signalinfo.wrmode_ = info.wrmode;
        catch
            signalinfo.wrmode_ = 'reverse';
        end
        obj.opensignal_ = signalinfo;
        %
        try
            signalinfo.overrideriskmanagername_ = info.overrideriskmanagername;
        catch
            signalinfo.overrideriskmanagername_ = '';
        end
        %
        try
            signalinfo.overridepxtarget_ = info.overridepxtarget;
        catch
            signalinfo.overridepxtarget_ = -9.99;
        end
        %
        try
            signalinfo.overridepxstoploss_ = info.overridepxstoploss;
        catch
            signalinfo.overridepxstoploss_ = -9.99;
        end
        %
        return
    end
    
    if strcmpi(name,'batmanmanual')
        signalinfo = cBatmanManual;
        try
            signalinfo.frequency_ = info.frequency;
        catch
            signalinfo.frequency_ = '';
        end
        %
        try
            signalinfo.pxtarget_ = info.pxtarget;
        catch
            signalinfo.pxtarget_ = [];
        end
        %
        try
            signalinfo.pxstoploss_ = info.pxstoploss;
        catch
            signalinfo.pxstoploss_ = [];
        end
        obj.opensignal_ = signalinfo;
        return
    end
    
    if strcmpi(name,'paircointegration')
        return
    end
    
    if strcmpi(name,'tdsq')
        signalinfo = cTDSQInfo;
        try
            signalinfo.frequency_ = info.frequency;
        catch
            signalinfo.frequency_ = '';
        end
        %
        try
            signalinfo.scenario_ = info.scenarioname;
        catch
            signalinfo.scenario_ = '';
        end
        %
        try 
            signalinfo.mode_ = info.mode;
        catch
            signalinfo.mode_ = 'reverse';
        end
        obj.opensignal_ = signalinfo;
        return
    end
    
    
    error('cTradeOpen:setsignalinfo:%s not implemented',name);
    
end