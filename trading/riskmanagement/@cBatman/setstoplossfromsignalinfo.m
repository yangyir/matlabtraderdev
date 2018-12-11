function [] = setstoplossfromsignalinfo(obj,signalinfo)
%cBatman
    if isempty(signalinfo), return; end

    if ~isa(signalinfo,'cSignalInfo')
        error('cBatman::settargetfromsignal:invalid signalinfo input')
    end
    
    if isa(signalinfo,'cWilliamsRInfo')
        pxhighest = signalinfo.highesthigh_;
        pxlowest = signalinfo.lowestlow_;
        pxopen = obj.trade_.openprice_;
        direction = obj.trade_.opendirection_;
        if obj.bandstoploss_ ~= -9.99
            stoploss =  direction*(pxhighest-pxlowest)*obj.bandstoploss_;
            tickSize = obj.trade_.instrument_.tick_size;
            obj.pxstoploss_ = pxopen - round(stoploss/tickSize)*tickSize;
        else
            obj.pxstoploss_ = NaN;
        end
        return
    end
    
    if isa(signalinfo,'cBatmanManual')
        obj.pxstoploss_ = signalinfo.pxstoploss_;
        return
    end
    
    error('cBatman::settargetfromsignal:%s not supported',signalinfo.name_)
    
end