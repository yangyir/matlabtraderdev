function [tradenew] = runsingletradebest(obj,tradein,varargin)
% a cFORM utility function to re-run the backtest of the input trade

    code = tradein.code_;
    opendt = tradein.opendatetime1_;

    [flag,idx] = obj.hascode(code);

    if ~flag
        return
    end

    ei = obj.ei_signal_{idx};

    checkstartidx = find(ei.px(:,1) >= opendt,1,'first');
    nbars = size(ei.px,1);
    opensignal = tradein.opensignal_.mode_;
    direction = tradein.opendirection_;
    freq = tradein.opensignal_.frequency_;
    nfractal = charlotte_freq2nfractal(freq);

    tradenew = fractal_gentrade(ei,code,checkstartidx,opensignal,direction,freq,nfractal,1);
    tradenew.riskmanager_.setusefractalupdateflag(0);
    tradenew.riskmanager_.setusefibonacciflag(1);

    for k = checkstartidx:nbars
        extrainfo = fractal_truncate(ei,k);
        extrainfo.latestopen = extrainfo.px(end,5);
        extrainfo.latestdt = extrainfo.px(end,1);
        ut = tradenew.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',extrainfo);
        if ~isempty(ut)
            break
        else
            fprintf('%f->%f\n',tradenew.riskmanager_.pxstoploss2_,extrainfo.latestopen)
        end
    end



end