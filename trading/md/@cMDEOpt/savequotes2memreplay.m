function [] = savequotes2memreplay(mdeopt)
% a cMDEOpt function
% used ONLY with replay mode
    if ~strcmpi(mdeopt.mode_,'replay'), return;end
    
    %qo.quotes_ = qo.qms_.getquote;
    %cQMS doesnot work in replay mode and we shall create quotes ourselves
    
    if isempty(mdeopt.ticksquick_), return;end
    
    if mdeopt.ticksquick_(1,4) == 0, return;end
    
        n = mdeopt.qms_.instruments_.count;
    
    quotes = cell(n,1);
    
    qu = cQuoteFut;
    qu.init(mdeopt.underlier_.code_ctp);
    qu.last_trade = mdeopt.ticksquick_(1,4);
    qu.bid1 = qu.last_trade;
    qu.ask1 = qu.last_trade;
    qu.bid_size1 = 1;
    qu.ask_size1 = 1;
    qu.update_date1 = floor(mdeopt.ticksquick_(1,1));
    qu.update_date2 = datestr(qu.update_date1,'yyyy-mm-dd');
    qu.update_time1 = mdeopt.ticksquick_(1,1);
    qu.update_time2 = datestr(qu.update_time1,'yyyy-mm-dd HH:MM:SS');
    quotes{1,1} = qu;
    
    no = mdeopt.options_.count;
    options = mdeopt.options_.getinstrument;
    for i = 1:no
        qo = cQuoteOpt;
        qo.init(options{i}.code_ctp);
        qo.last_trade_underlier = qu.last_trade;
        qo.bid_underlier = qu.bid1;
        qo.ask_underlier = qu.ask1;
        qo.bid_size_underlier = qu.bid_size1;
        qo.ask_size_underlier = qu.ask_size1;
        qo.last_trade = mdeopt.ticksquick_(1+i,4);
        qo.bid1 = qo.last_trade;
        qo.ask1 = qo.last_trade;
        qo.bid_size1 = 1;
        qo.ask_size1 = 1;
        qo.update_date1 = floor(mdeopt.ticksquick_(1+i,1));
        qo.update_date2 = datestr(qo.update_date1,'yyyy-mm-dd');
        qo.update_time1 = mdeopt.ticksquick_(1+i,1);
        qo.update_time2 = datestr(qo.update_time1,'yyyy-mm-dd HH:MM:SS');
        
        hh = hour(qo.update_time1);
        isevening = hh > 15 && hh < 24;
        if isevening
            cob_date = businessdate(qo.update_date1);
        else
            cob_date = qo.update_date1;
        end
        qo.opt_calendar_tau = (qo.opt_expiry_date1 - cob_date)/365;
        bds = gendates('fromdate',cob_date,'todate',qo.opt_expiry_date1);
        qo.opt_business_tau = length(bds)/252;
        
        qo.riskless_rate = 0.01;
        %calculate implied vols
        if qo.opt_american
            mid = 0.5*(qo.bid_underlier + qo.ask_underlier);
            if (qo.ask1 - qo.bid1)/qo.last_trade < 0.05
                midopt = qo*(qo.bid1 + qo.ask1);
            else
                midopt = qo.last_trade;
            end
            r = qo.riskless_rate;
            if strcmpi(qo.opt_type,'C')
                opttype = 'call';
            else
                opttype = 'put';
            end
            warning('off')
            qo.impvol = bjsimpv(mid,qo.opt_strike,r,cob_date,...
                qo.opt_expiry_date1,midopt,[],r,[],opttype);
            if isnan(qo.impvol ) || qo.impvol == 0
                qo.impvol = 0.01;
            end
        else
            mid = 0.5*(qo.bid_underlier + qo.ask_underlier);
            if (qo.ask1 - qo.bid1)/qo.last_trade < 0.05
                midopt = 0.5*(qo.bid1 + qo.ask1);
            else
                midopt = qo.last_trade;
            end
            r = qo.riskless_rate;
            if strcmpi(qo.opt_type,'C')
                opttype = 'Calls';
            else
                opttype = 'Puts';
            end
            warning('off')
            qo.impvol = blkimpv(mid,qo.opt_strike,r,qo.opt_calendar_tau,midopt,[],[],{opttype});
            if isnan(qo.impvol ) || qo.impvol == 0
                qo.impvol = 0.01;
            end
        end
        
        %calculate delta/gamma
        if qo.opt_american
            midUp = mid*(1+0.005);
            midDn = mid*(1-0.005);
            if strcmpi(qo.opt_type,'C')
                pxUp = bjsprice(midUp,qo.opt_strike,r,cob_date,qo.opt_expiry_date1,qo.impvol,r);
                pxDn = bjsprice(midDn,qo.opt_strike,r,cob_date,qo.opt_expiry_date1,qo.impvol,r);
            else
                [~,pxUp] = bjsprice(midUp,qo.opt_strike,r,cob_date,qo.opt_expiry_date1,qo.impvol,r);
                [~,pxDn] = bjsprice(midDn,qo.opt_strike,r,cob_date,qo.opt_expiry_date1,qo.impvol,r);
            end
            %note:we record the percentage level delta and gamma
            qo.delta = (pxUp - pxDn)/(midUp-midDn);
            qo.gamma = (pxUp+pxDn-qo.bid1-qo.ask1)/(0.005^2)*0.01/mid;
        else
            midUp = mid*(1+0.005);
            midDn = mid*(1-0.005);
            if strcmpi(qo.opt_type,'C')
                pxUp = blkprice(midUp,qo.opt_strike,r,qo.opt_calendar_tau,qo.impvol);
                pxDn = blkprice(midDn,qo.opt_strike,r,qo.opt_calendar_tau,qo.impvol);
            else
                [~,pxUp] = blkprice(midUp,qo.opt_strike,r,qo.opt_calendar_tau,qo.impvol);
                [~,pxDn] = blkprice(midDn,qo.opt_strike,r,qo.opt_calendar_tau,qo.impvol);
            end
            %note:we record the percentage level delta and gamma
            qo.delta = (pxUp - pxDn)/(midUp-midDn);
            qo.gamma = (pxUp+pxDn-qo.bid1-qo.ask1)/(0.005^2)*0.01/mid;
        end

        %calculate theta
        if qo.opt_american
            datecarry = businessdate(cob_date);
            if strcmpi(qo.opt_type,'C')
                pxCarry = bjsprice(mid,qo.opt_strike,r,datecarry,qo.opt_expiry_date1,qo.impvol,r);
            else
                [~,pxCarry] = bjsprice(mid,qo.opt_strike,r,datecarry,qo.opt_expiry_date1,qo.impvol,r);
            end
            qo.theta = pxCarry - 0.5*(qo.bid1 + qo.ask1);
        else
            datecarry = businessdate(cob_date);
            tau = (qo.opt_expiry_date1 - datecarry)/365;
            if strcmpi(qo.opt_type,'C')
                pxCarry = blkprice(mid,qo.opt_strike,r,tau,qo.impvol);
            else
                [~,pxCarry] = blkprice(mid,qo.opt_strike,r,tau,qo.impvol);
            end
            qo.theta = pxCarry - 0.5*(qo.bid1 + qo.ask1);
        end

        %calculate vega
        if qo.opt_american
            ivUp = qo.impvol + 0.005;
            ivDn = qo.impvol - 0.005;
            if strcmpi(qo.opt_type,'C')
                pxVolUp = bjsprice(mid,qo.opt_strike,r,cob_date,qo.opt_expiry_date1,ivUp,r);
                pxVolDn = bjsprice(mid,qo.opt_strike,r,cob_date,qo.opt_expiry_date1,ivDn,r);
            else
                [~,pxVolUp] = bjsprice(mid,qo.opt_strike,r,cob_date,qo.opt_expiry_date1,ivUp,r);
                [~,pxVolDn] = bjsprice(mid,qo.opt_strike,r,cob_date,qo.opt_expiry_date1,ivDn,r);
            end
            qo.vega = pxVolUp - pxVolDn;
        else
            ivUp = qo.impvol + 0.005;
            ivDn = qo.impvol - 0.005;
            if strcmpi(qo.opt_type,'C')
                pxVolUp = blkprice(mid,qo.opt_strike,r,qo.opt_calendar_tau,ivUp);
                pxVolDn = blkprice(mid,qo.opt_strike,r,qo.opt_calendar_tau,ivDn);
            else
                [~,pxVolUp] = blkprice(mid,qo.opt_strike,r,qo.opt_calendar_tau,ivUp);
                [~,pxVolDn] = blkprice(mid,qo.opt_strike,r,qo.opt_calendar_tau,ivDn);
            end
            qo.vega = pxVolUp - pxVolDn;    
        end
        
        quotes{i+1,1} = qo;
        
    end
    
    mdeopt.quotes_ = quotes;
end