function [] = settargetfromsignalinfo(obj,signalinfo)
    if isempty(signalinfo), return; end
    
    if ~isa(signalinfo,'cSignalInfo')
        error('cBatman::settargetfromsignal:invalid signalinfo input')
    end
    
    if isa(signalinfo,'cWilliamsRInfo')
        pxhighest = signalinfo.highesthigh_;
        pxlowest = signalinfo.lowestlow_;
        pxopen = obj.trade_.openprice_;
        direction = obj.trade_.opendirection_;
        if obj.bandtarget_ ~= -9.99
            target = direction*(pxhighest-pxlowest)*obj.bandtarget_;
            tickSize = obj.trade_.instrument_.tick_size;
            obj.pxtarget_ = pxopen + round(target/tickSize)*tickSize;
        else
            obj.pxtarget_ = NaN;
        end
        return
    end
    
    if isa(signalinfo,'cBatmanManual') || isa(signalinfo,'cManualInfo')
        obj.pxtarget_ = signalinfo.pxtarget_;
        return
    end
    
    error('cBatman::settargetfromsignal:%s not supported',signalinfo.name_)
    
end