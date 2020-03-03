function [] = loadmktdata(obj,varargin)
%cMDEOpt
    no = size(obj.options_,1);
    lastbd = getlastbusinessdate;
    
    for i = 1:no
        prbd = pnlriskbreakdownbbg(obj.options_{i},lastbd);
        obj.deltacarryyesterday_(i) = prbd.deltacarry;
        obj.gammacarryyesterday_(i) = prbd.gammacarry;
        obj.vegacarryyesterday_(i) = prbd.vegacarry;
        obj.thetacarryyesterday_(i) = prbd.thetacarry;
        obj.impvolcarryyesterday_(i) = prbd.iv2;
        obj.pvcarryyesterday_(i) = prbd.premium2;
        obj.fwdyesterday_(i) = prbd.fwd2;
        obj.spotyesterday_(i) = prbd.spot2;
    end
    
    fprintf('%s:loadmktdata called...\n',class(obj));
    
end