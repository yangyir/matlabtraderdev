function [] = setstoplossfromsignalinfo(obj,signalinfo)
    if isempty(signalinfo), return; end

    if ~isa(signalinfo,'cSignalInfo')
        error('cBatman::settargetfromsignal:invalid signalinfo input')
    end
    
    if isa(signalinfo,'cWilliamsRInfo')
        pxhighest = signalinfo.highesthigh_;
        pxlowest = signalinfo.lowestlow_;
        pxopen = obj.trade_.openprice_;
        direction = obj.trade_.opendirection_;
        stoploss =  direction*(pxhighest-pxlowest)*obj.bandstoploss_;
        tickSize = obj.trade_.instrument_.tick_size;
        obj.pxstoploss_ = pxopen - round(stoploss/tickSize)*tickSize;
        
        return
    end
    
    if isa(signalinfo,'cBatmanManual')
        obj.pxstoploss_ = signalinfo.pxstoploss_;
    end
    
    error('cBatman::settargetfromsignal:%s not supported',signalinfo.name_)
    
end