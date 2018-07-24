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
        target = pxopen + direction*(pxhighest-pxlowest)*obj.bandtarget_;
        tickSize = obj.trade_.instrument_.tick_size;
        obj.pxtarget_ = round(target/tickSize)*tickSize;
        return
    end
    
    error('cBatman::settargetfromsignal:%s not supported',signalinfo.name_)
    
end