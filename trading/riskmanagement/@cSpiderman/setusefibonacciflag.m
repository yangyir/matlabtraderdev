function [] = setusefibonacciflag(obj,flagin)
% a cSpiderman method
    if ~(flagin == 0 || flagin == 1)
        error('cSpiderman:setusefibonacciflag:invaldi input')
    end
    
    obj.usefibonacci_ = flagin;
end