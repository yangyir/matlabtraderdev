function [] = refresh(obj,varargin)
% a cMDEOpt function
    if ~isempty(obj.qms_)
        if strcmpi(obj.mode_,'realtime')
            obj.qms_.refresh;
        else
            return
%                     error('to be finished')
        end

        obj.savequotes2mem;
        
        fprintf('%s mdeopt runs......\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
%         if obj.printflag_, obj.displaypivottable; end
        if ~obj.qms_.watcher_.calcgreeks,return;end

        %fill greeks
        options = obj.options_.getinstrument;
        for i = 1:size(options,1)
            q = obj.qms_.getquote(options{i});
            mult = options{i}.contract_size;
            if isempty(q), continue;end
            obj.delta_(i,1) = q.delta*mult*q.last_trade_underlier;
            obj.gamma_(i,1) = q.gamma*mult*q.last_trade_underlier;
            obj.vega_(i,1) = q.vega*mult;
            obj.theta_(i,1) = q.theta*mult;
            obj.impvol_(i,1) = q.impvol;
            %carry
            nextdate = businessdate(q.update_date1,1);
            expirydate = options{i}.opt_expiry_date1;
            bump = 0.005;
            px = q.last_trade_underlier;
            pxup = px*(1+bump);
            pxdn = px*(1-bump);
            k = options{i}.opt_strike;
            iv = q.impvol;
            r = 0.02;
            if options{i}.opt_american
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
%                 tau = q.opt_business_tau-1/252;
                tau = (expirydate - nextdate)/365;
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

    end
end
%end of refresh