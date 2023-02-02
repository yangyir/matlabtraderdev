function [] = setusefibonacciflag(obj,flagin)
% a cSpiderman method
    if ~islogical(flagin)
        error('cSpiderman:setusefibonacciflag:invaldi input')
    end
    
    obj.usefibonacci_ = flagin;
end