function [] = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_,underlier_quote_,calcgreeks)
%cQuoteOpt
    if ~obj.init_flag
        obj.init(codestr);
    end

    if nargin == 10, calcgreeks = true; end

    update@cQuoteFut(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_);
    %note: we always use the mid price to imply the volatility
    %which shall be used for calculate delta,gamma,vega,theta...

    if ~isa(underlier_quote_,'cQuoteFut')
        error('cQuoteOpt:update:invalid underlier quote input')
    end

    obj.code_ctp_underlier = underlier_quote_.code_ctp;
    obj.code_wind_underlier = underlier_quote_.code_wind;
    obj.code_bbg_underlier = underlier_quote_.code_bbg;
    obj.last_trade_underlier = underlier_quote_.last_trade;
    obj.bid_underlier = underlier_quote_.bid1;
    obj.ask_underlier = underlier_quote_.ask1;
    obj.bid_size_underlier = underlier_quote_.bid_size1;
    obj.ask_size_underlier = underlier_quote_.ask_size1;

    hh = hour(obj.update_time1);
    isevening = hh > 15 && hh < 24;
    if isevening
        cob_date = businessdate(obj.update_date1);
    else
        cob_date = obj.update_date1;
    end

    obj.opt_calendar_tau = (obj.opt_expiry_date1 - cob_date)/365;
    bds = gendates('fromdate',cob_date,'todate',obj.opt_expiry_date1);
    obj.opt_business_tau = length(bds)/252;

    if ~calcgreeks, return; end
    %calculate implied vols
    if obj.opt_american
        mid = 0.5*(obj.bid_underlier + obj.ask_underlier);
        %note:20190221
        %bid-ask spread sometimes are very wild on market close, in such
        %case we shall use last_trade instead
        if (obj.ask1 - obj.bid1)/obj.last_trade < 0.05
            midopt = 0.5*(obj.bid1 + obj.ask1);
        else
            midopt = obj.last_trade;
        end
        r = obj.riskless_rate;
        if strcmpi(obj.opt_type,'C')
            opttype = 'call';
        else
            opttype = 'put';
        end
        warning('off')
        obj.impvol = bjsimpv(mid,obj.opt_strike,r,cob_date,...
            obj.opt_expiry_date1,midopt,[],r,[],opttype);
        if isnan(obj.impvol ) || obj.impvol == 0
            obj.impvol = 0.01;
        end
    else
        mid = 0.5*(obj.bid_underlier + obj.ask_underlier);
        midopt = 0.5*(obj.bid1 + obj.ask1);
        %note:20190221
        %bid-ask spread sometimes are very wild on market close, in such
        %case we shall use last_trade instead
        if (obj.ask1 - obj.bid1)/obj.last_trade < 0.05
            midopt = 0.5*(obj.bid1 + obj.ask1);
        else
            midopt = obj.last_trade;
        end
        r = obj.riskless_rate;
        if strcmpi(obj.opt_type,'C')
            opttype = 'Calls';
        else
            opttype = 'Puts';
        end
        warning('off')
%         obj.impvol = blkimpv(mid,obj.opt_strike,r,obj.opt_business_tau,midopt,[],[],{opttype});
        obj.impvol = blkimpv(mid,obj.opt_strike,r,obj.opt_calendar_tau,midopt,[],[],{opttype});
        if isnan(obj.impvol ) || obj.impvol == 0
            obj.impvol = 0.01;
        end
        
    end


    %calculate delta/gamma
    if obj.opt_american
        midUp = mid*(1+0.005);
        midDn = mid*(1-0.005);
        if strcmpi(obj.opt_type,'C')
            pxUp = bjsprice(midUp,obj.opt_strike,r,cob_date,obj.opt_expiry_date1,obj.impvol,r);
            pxDn = bjsprice(midDn,obj.opt_strike,r,cob_date,obj.opt_expiry_date1,obj.impvol,r);
        else
            [~,pxUp] = bjsprice(midUp,obj.opt_strike,r,cob_date,obj.opt_expiry_date1,obj.impvol,r);
            [~,pxDn] = bjsprice(midDn,obj.opt_strike,r,cob_date,obj.opt_expiry_date1,obj.impvol,r);
        end
        %note:we record the percentage level delta and gamma
        obj.delta = (pxUp - pxDn)/(midUp-midDn);
        obj.gamma = (pxUp+pxDn-obj.bid1-obj.ask1)/(0.005^2)*0.01/mid;
    else
        midUp = mid*(1+0.005);
        midDn = mid*(1-0.005);
        if strcmpi(obj.opt_type,'C')
            pxUp = blkprice(midUp,obj.opt_strike,r,obj.opt_calendar_tau,obj.impvol);
            pxDn = blkprice(midDn,obj.opt_strike,r,obj.opt_calendar_tau,obj.impvol);
        else
            [~,pxUp] = blkprice(midUp,obj.opt_strike,r,obj.opt_calendar_tau,obj.impvol);
            [~,pxDn] = blkprice(midDn,obj.opt_strike,r,obj.opt_calendar_tau,obj.impvol);
        end
        %note:we record the percentage level delta and gamma
        obj.delta = (pxUp - pxDn)/(midUp-midDn);
        obj.gamma = (pxUp+pxDn-obj.bid1-obj.ask1)/(0.005^2)*0.01/mid;
    end

    %calculate theta
    if obj.opt_american
        datecarry = businessdate(cob_date);
        if strcmpi(obj.opt_type,'C')
            pxCarry = bjsprice(mid,obj.opt_strike,r,datecarry,obj.opt_expiry_date1,obj.impvol,r);
        else
            [~,pxCarry] = bjsprice(mid,obj.opt_strike,r,datecarry,obj.opt_expiry_date1,obj.impvol,r);
        end
        obj.theta = pxCarry - 0.5*(obj.bid1 + obj.ask1);
    else
        datecarry = businessdate(cob_date);
        tau = (obj.opt_expiry_date1 - datecarry)/365;
        if strcmpi(obj.opt_type,'C')
            pxCarry = blkprice(mid,obj.opt_strike,r,tau,obj.impvol);
        else
            [~,pxCarry] = blkprice(mid,obj.opt_strike,r,tau,obj.impvol);
        end
        obj.theta = pxCarry - 0.5*(obj.bid1 + obj.ask1);
    end

    %calculate vega
    if obj.opt_american
        ivUp = obj.impvol + 0.005;
        ivDn = obj.impvol - 0.005;
        if strcmpi(obj.opt_type,'C')
            pxVolUp = bjsprice(mid,obj.opt_strike,r,cob_date,obj.opt_expiry_date1,ivUp,r);
            pxVolDn = bjsprice(mid,obj.opt_strike,r,cob_date,obj.opt_expiry_date1,ivDn,r);
        else
            [~,pxVolUp] = bjsprice(mid,obj.opt_strike,r,cob_date,obj.opt_expiry_date1,ivUp,r);
            [~,pxVolDn] = bjsprice(mid,obj.opt_strike,r,cob_date,obj.opt_expiry_date1,ivDn,r);
        end
        obj.vega = pxVolUp - pxVolDn;
    else
        ivUp = obj.impvol + 0.005;
        ivDn = obj.impvol - 0.005;
        if strcmpi(obj.opt_type,'C')
            pxVolUp = blkprice(mid,obj.opt_strike,r,obj.opt_calendar_tau,ivUp);
            pxVolDn = blkprice(mid,obj.opt_strike,r,obj.opt_calendar_tau,ivDn);
        else
            [~,pxVolUp] = blkprice(mid,obj.opt_strike,r,obj.opt_calendar_tau,ivUp);
            [~,pxVolDn] = blkprice(mid,obj.opt_strike,r,obj.opt_calendar_tau,ivDn);
        end
        obj.vega = pxVolUp - pxVolDn;    
    end

end