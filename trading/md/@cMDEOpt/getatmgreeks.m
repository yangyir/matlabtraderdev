function res = getatmgreeks(mdeopt,code_ctp_underlier,varargin)
%cMDEOpt
    qu = mdeopt.qms_.getquote(code_ctp_underlier);
    strikeATM = qu.last_trade;

    if ~isempty(strfind(code_ctp_underlier,'m'))
        optformat = 1;
        bucketsize = 50;
    elseif ~isempty(strfind(code_ctp_underlier,'SR'))
        optformat = 2;
        bucketsize = 100;
    elseif ~isempty(strfind(code_ctp_underlier,'cu'))
        optformat = 2;
        if strikeATM <= 40000
            bucketsize = 500;
        elseif strikeATM > 40000 && strikeATM < 80000
            bucketsize = 1000;
        else
            bucketsize = 2000;
        end
    else
        error('getlistedoptions:unknown underlier')
    end
    
    strike1 = floor(strikeATM/bucketsize)*bucketsize;  %lower strike
    strike2 = ceil(strikeATM/bucketsize)*bucketsize;   %upper strike
    w1 = (strike2-strikeATM)/(strike2-strike1);
    w2 = 1-w1;
    %%
    if optformat == 1
        c1 = [code_ctp_underlier,'-C-',num2str(strike1)];
        c2 = [code_ctp_underlier,'-C-',num2str(strike2)];
        p1 = [code_ctp_underlier,'-P-',num2str(strike1)];
        p2 = [code_ctp_underlier,'-P-',num2str(strike2)];
    else
        c1 = [code_ctp_underlier,'C',num2str(strike1)];
        c2 = [code_ctp_underlier,'C',num2str(strike2)];
        p1 = [code_ctp_underlier,'P',num2str(strike1)];
        p2 = [code_ctp_underlier,'P',num2str(strike2)];
    end
    
    c1_greeks = mdeopt.getgreeks(c1);
    c2_greeks = mdeopt.getgreeks(c2);
    p1_greeks = mdeopt.getgreeks(p1);
    p2_greeks = mdeopt.getgreeks(p2);
    
    ivatm_c = w1*c1_greeks.impvol+w2*c2_greeks.impvol;
    ivatm_p = w1*p1_greeks.impvol+w2*p2_greeks.impvol;
    %
    opt = code2instrument(c1);
    r = 0.035;
    bump = 0.005;
    nextdate = businessdate(qu.update_date1,1);
    expirydate = opt.opt_expiry_date1;
    mult = opt.contract_size;
    if opt.opt_american
    
    
            if isempty(q), continue;end
            obj.delta_(i,1) = q.delta*mult*q.last_trade_underlier;
            obj.gamma_(i,1) = q.gamma*mult*q.last_trade_underlier;
            obj.vega_(i,1) = q.vega*mult;
            obj.theta_(i,1) = q.theta*mult;
            obj.impvol_(i,1) = q.impvol;
            %carry
            
            
            
            px = q.last_trade_underlier;
            pxup = px*(1+bump);
            pxdn = px*(1-bump);
            k = options{i}.opt_strike;
            iv = q.impvol;
            r = 0.035;
            
                if strcmpi(options{i}.opt_type,'C')
                    pvcarry = bjsprice(px,k,r,nextdate,expirydate,iv,r);
                    pvcarryup = bjsprice(pxup,k,r,nextdate,expirydate,iv,r);
                    pvcarrydn = bjsprice(pxdn,k,r,nextdate,expirydate,iv,r);
                else
                    [~,pvcarry] = bjsprice(px,k,r,nextdate,expirydate,iv,r);
                    [~,pvcarryup] = bjsprice(pxup,k,r,nextdate,expirydate,iv,r);
                    [~,pvcarrydn] = bjsprice(pxdn,k,r,nextdate,expirydate,iv,r);
                end
            else
                tau = q.opt_business_tau-1/252;
                if strcmpi(options{i}.opt_type,'C')
                    pvcarry = blkprice(px,k,r,tau,iv);
                    pvcarryup = blkprice(pxup,k,r,tau,iv);
                    pvcarrydn = blkprice(pxdn,k,r,tau,iv);
                else
                    [~,pvcarry] = blkprice(px,k,r,tau,iv);
                    [~,pvcarryup] = blkprice(pxup,k,r,tau,iv);
                    [~,pvcarrydn] = blkprice(pxdn,k,r,tau,iv);
                end
            end
            obj.thetacarry_(i,1) = q.theta*mult;
            deltacarry = (pvcarryup-pvcarrydn)/(pxup-pxdn);
            gammacarry = (pvcarryup+pvcarrydn-2*pvcarry)/(bump*px)^2*px/100;
            obj.deltacarry_(i,1) = deltacarry*mult*px;
            obj.gammacarry_(i,1) = gammacarry*mult*px;
            %vegacarry
            if options{i}.opt_american
                if strcmpi(options{i}.opt_type,'C')
                    pvvolup = bjsprice(px,k,r,nextdate,expirydate,iv+bump,r);
                    pvvoldn = bjsprice(px,k,r,nextdate,expirydate,iv-bump,r);
                else
                    [~,pvvolup] = bjsprice(px,k,r,nextdate,expirydate,iv+bump,r);
                    [~,pvvoldn] = bjsprice(px,k,r,nextdate,expirydate,iv-bump,r);
                end
            else
                if strcmpi(options{i}.opt_type,'C')
                    pvvolup = blkprice(px,k,r,tau,iv+bump);
                    pvvoldn = blkprice(px,k,r,tau,iv-bump);
                else
                    [~,pvvolup] = blkprice(px,k,r,tau,iv+bump);
                    [~,pvvoldn] = blkprice(px,k,r,tau,iv-bump);
                end
            end
            vegacarry = pvvolup - pvvoldn;
            obj.vegacarry_(i,1) = vegacarry*mult;
    
    
    
    
    
    
end