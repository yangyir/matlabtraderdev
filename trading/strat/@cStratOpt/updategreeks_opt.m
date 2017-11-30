function [] = updategreeks_opt(stratopt)
    n = stratopt.count;
    %real-time greeks
    for i = 1:n
        opt = stratopt.instruments_.getinstrument{i};
        if ~isa(opt,'cOption'), continue;end
        mult = opt.contract_size;
        q = stratopt.mde_opt_.qms_.getquote(opt);

        if ~isempty(q)
            px = q.last_trade_underlier;
            stratopt.setriskvalue(opt,'delta',q.delta*mult*px);
            stratopt.setriskvalue(opt,'gamma',q.gamma*mult*px);
            stratopt.setriskvalue(opt,'vega',q.vega*mult);
            stratopt.setriskvalue(opt,'theta',q.theta*mult);
            %note:the implied vol from the quote object is using
            %the mid price of both the option and its underlier
            %                     obj.setriskvalue(opt,'impvol',q.impvol);
            %compute carry risk
            r = 0.035;
            nextdate = businessdate(q.update_date1,1);
            expirydate = opt.opt_expiry_date1;
            %note:we now use the last trade price of the option and
            %its underlier to imply the volatility and this is for
            %the risk/pnl explanation purpose
            pv_opt = q.last_trade;
            pv_fut = q.last_trade_underlier;
            k = opt.opt_strike;
            tau = (expirydate-nextdate)/365;
            optclass = 'call';
            if strcmpi(opt.opt_type,'p'),optclass = 'put';end
            if opt.opt_american
                iv = bjsimpv(pv_fut,k,r,q.update_date1,expirydate,pv_opt,[],r,[],optclass);
            else
                iv = blkimpv(pv_fut,k,r,tau,pv_opt,[],[],{optclass});
            end
            stratopt.setriskvalue(opt,'impvol',iv);

            bump = 0.005;
            pxup = px*(1+bump);
            pxdn = px*(1-bump);
            %pvcarry
            if opt.opt_american
                if strcmpi(opt.opt_type,'C')
                    pvcarry = bjsprice(px,k,r,nextdate,expirydate,iv,r);
                    pvcarryup = bjsprice(pxup,k,r,nextdate,expirydate,iv,r);
                    pvcarrydn = bjsprice(pxdn,k,r,nextdate,expirydate,iv,r);
                else
                    [~,pvcarry] = bjsprice(px,k,r,nextdate,expirydate,iv,r);
                    [~,pvcarryup] = bjsprice(pxup,k,r,nextdate,expirydate,iv,r);
                    [~,pvcarrydn] = bjsprice(pxdn,k,r,nextdate,expirydate,iv,r);
                end
            else
                if strcmpi(opt.opt_type,'C')
                    pvcarry = blkprice(px,k,r,tau,iv);
                    pvcarryup = blkprice(pxup,k,r,tau,iv);
                    pvcarrydn = blkprice(pxdn,k,r,tau,iv);
                else
                    [~,pvcarry] = blkprice(px,k,r,tau,iv);
                    [~,pvcarryup] = blkprice(pxup,k,r,tau,iv);
                    [~,pvcarrydn] = blkprice(pxdn,k,r,tau,iv);
                end
            end
            %thetacarry
            stratopt.setriskvalue(opt,'thetacarry',q.theta*mult);
            %deltacarry
            deltacarry = (pvcarryup-pvcarrydn)/(pxup-pxdn);
            gammacarry = (pvcarryup+pvcarrydn-2*pvcarry)/(bump*px)^2*px/100;
            stratopt.setriskvalue(opt,'deltacarry',deltacarry*mult*px);
            stratopt.setriskvalue(opt,'gammacarry',gammacarry*mult*px);
            %vegacarry
            if opt.opt_american
                if strcmpi(opt.opt_type,'C')
                    pvvolup = bjsprice(px,k,r,nextdate,expirydate,iv+bump,r);
                    pvvoldn = bjsprice(px,k,r,nextdate,expirydate,iv-bump,r);
                else
                    [~,pvvolup] = bjsprice(px,k,r,nextdate,expirydate,iv+bump,r);
                    [~,pvvoldn] = bjsprice(px,k,r,nextdate,expirydate,iv-bump,r);
                end
            else
                if strcmpi(opt.opt_type,'C')
                    pvvolup = blkprice(px,k,r,tau,iv+bump);
                    pvvoldn = blkprice(px,k,r,tau,iv-bump);
                else
                    [~,pvvolup] = blkprice(px,k,r,tau,iv+bump);
                    [~,pvvoldn] = blkprice(px,k,r,tau,iv-bump);
                end
            end
            vegacarry = pvvolup - pvvoldn;
            stratopt.setriskvalue(opt,'vegacarry',vegacarry*mult);
        end
    end
    %end of update risk for options

    nu = stratopt.countunderliers;
    for i = 1:nu
        fut = stratopt.underliers_.getinstrument{i};
        mult = fut.contract_size;
        q = stratopt.mde_fut_.qms_.getquote(fut);

        if ~isempty(q)
            px = q.last_trade;
            stratopt.setriskvalue(fut,'delta',px*mult);
        end
    end
end
%end of updategreeks