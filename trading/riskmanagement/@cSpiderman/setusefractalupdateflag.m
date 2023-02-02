function [] = setusefractalupdateflag(obj,flagin)
% a cSpiderman method
    if ~islogical(flagin)
        error('cSpiderman:setusefractalupdateflag:invalid input')
    end

    obj.usefractalupdate_ = flagin;
end