function [] = setusefractalupdateflag(obj,flagin)
% a cSpiderman method
    if ~(flagin == 0 || flagin == 1)
        error('cSpiderman:setusefractalupdateflag:invalid input')
    end

    obj.usefractalupdate_ = flagin;
end