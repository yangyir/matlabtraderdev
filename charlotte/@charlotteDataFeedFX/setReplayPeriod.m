function [] = setReplayPeriod(obj,rplfrom,rplto)
% a charlotteDataFeedFX function
    obj.mode_ = 'replay';
    
    if isnumeric(rplfrom)
        obj.replaydatefrom_ = rplfrom;
    else
        obj.replaydatefrom_ = datenum(rplfrom);
    end
    
    if isnumeric(rplto)
        obj.replaydateto_ = rplto;
    else
        obj.replaydateto_ = datenum(rplto);
    end

end