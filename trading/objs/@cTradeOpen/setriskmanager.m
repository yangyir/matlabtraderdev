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
            riskmanager.status_ = info.status_;
        catch
            riskmanager.status_ = 'unset';
        end
        try
            riskmanager.pxtarget_ = info.pxtarget_;
        catch
            riskmanager.pxtarget_ = -9.99;
        end
        try
            riskmanager.pxstoploss_ = info.pxstoploss_;
        catch
            riskmanager.pxstoploss_ = -9.99;
        end
        try
            riskmanager.bandwidthmin_ = info.bandwidthmin_;
        catch
            riskmanager.bandwidthmin_ = 0.3333;
        end
        try
            riskmanager.bandwidthmax_ = info.bandwidthmax_;
        catch
            riskmanager.bandwidthmax_ = 0.5;
        end
        try
            riskmanager.bandstoploss_ = info.bandstoploss_;
        catch
            riskmanager.bandstoploss_ = -9.99;
        end
        try
            riskmanager.bandtarget_ = info.bandtarget_;
        catch
            riskmanager.bandtarget_ = -9.99;
        end
        if info.bandstoploss_ ~= -9.99 && info.bandtarget_ ~= -9.99 && ...
                strcmpi( riskmanager.status_,'unset')
            riskmanager.setstoplossfromsignalinfo(obj.opensignal_);
            riskmanager.settargetfromsignalinfo(obj.opensignal_);
        end
        try
            riskmanager.pxsupportmin_ = info.pxsupportmin_;
        catch
            riskmanager.pxsupportmin_ = [];
        end
        try
            riskmanager.pxsupportmax_ = info.pxsupportmax_;
        catch
            riskmanager.pxsupportmax_ = [];
        end
        try
            riskmanager.pxresistence_ = info.pxresistence_;
        catch
            riskmanager.pxresistence_ = [];
        end
        try
            riskmanager.checkflag_ = info.checkflag_;
        catch
            riskmanager.checkflag_ = [];
        end
        try
            riskmanager.pxdynamicopen_ = info.pxdynamicopen_;
        catch
            riskmanager.pxdynamicopen_ = [];
        end
        obj.riskmanager_ = riskmanager;
        %
    elseif strcmpi(name,'standard')
        riskmanager = cStandard;
        riskmanager.trade_ = obj;
        try
            riskmanager.status_ = info.status_;
        catch
            riskmanager.status_ = 'unset';
        end
        try
            riskmanager.pxtarget_ = info.pxtarget_;
        catch
            riskmanager.pxtarget_ = -9.99;
        end
        try
            riskmanager.pxstoploss_ = info.pxstoploss_;
        catch
            riskmanager.pxstoploss_ = -9.99;
        end
        obj.riskmanager_ = riskmanager;
    elseif strcmpi(name,'wrstep')
        riskmanager = cWRStep;
        riskmanager.trade_ = obj;
        try
            riskmanager.status_ = info.status_;
        catch
            riskmanager.status_ = 'unset';
        end
        try
            riskmanager.pxtarget_ = info.pxtarget_;
        catch
            riskmanager.pxtarget_ = -9.99;
        end
        try
            riskmanager.pxstoploss_ = info.pxstoploss_;
        catch
            riskmanager.pxstoploss_ = -9.99;
        end
        try
            riskmanager.stepvalue_ = info.stepvalue_;
        catch
            riskmanager.stepvalue_ = 10;
        end
        try
            riskmanager.buffer_ = info.buffer_;
        catch
            riskmanager.buffer_ = 1;
        end
        
        obj.riskmanager_ = riskmanager;
    else
        error('cTradeOpen:setriskmanager:%s not supported',name);
    end
    
    
end