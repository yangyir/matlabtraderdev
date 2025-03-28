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
    
    if strcmpi(name,'fractal')
        signalinfo = cFractalInfo;
        try
            signalinfo.frequency_ = info.frequency;
        catch
            signalinfo.frequency_ = '';
        end
        %
        try
            signalinfo.type_ = info.type;
        catch
            signalinfo.type_ = 'unset';
        end
        %
        try
            signalinfo.mode_ = info.mode;
        catch
            signalinfo.mode_ = 'unset';
        end
        %
        try signalinfo.nfractal_ = info.nfractal;
        catch
            signalinfo.nfractal_ = [];
        end
        %
        try
            signalinfo.hh_ = info.hh;
        catch
            signalinfo.hh_ = [];
        end
        %
        try
            signalinfo.ll_ = info.ll;
        catch
            signalinfo.ll_ = [];
        end
        %
        try
            signalinfo.hh1_ = info.hh1;
        catch
            signalinfo.hh1_ = [];
        end
        %
        try
            signalinfo.ll1_ = info.ll1;
        catch
            signalinfo.ll1_ = [];
        end
        %
        try
            signalinfo.kelly_ = info.kelly;
        catch
            signalinfo.kelly_ = -9.99;
        end
        obj.opensignal_ = signalinfo;
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
            signalinfo.mode_ = 'unset';
        end
        %
        try
            signalinfo.type_ = info.type;
        catch
            signalinfo.type_ = 'unset';
        end
        %
        try
            signalinfo.lvlup_ = info.lvlup;
        catch
            signalinfo.lvlup_ = [];
        end
        %
        try
            signalinfo.lvldn_ = info.lvldn;
        catch
            signalinfo.lvldn_ = [];
        end
        %
        try
            signalinfo.risklvl_ = info.risklvl;
        catch
            signalinfo.risklvl_ = [];
        end
        %
        obj.opensignal_ = signalinfo;
        return
    end
    
    
    error('cTradeOpen:setsignalinfo:%s not implemented',name);
    
end