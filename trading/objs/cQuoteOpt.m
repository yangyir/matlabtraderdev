classdef cQuoteOpt < cQuoteFut
    %class of quotes for listed options
    properties
        code_ctp_underlier
        code_wind_underlier
        code_bbg_underlier

        %
        last_trade_underlier
        bid_underlier
        ask_underlier
        bid_size_underlier
        ask_size_underlier
        %
        opt_american = true    %商品期权
        opt_type
        opt_strike
        opt_expiry_date1       %date in number
        opt_expiry_date2       %date in string
        opt_calendar_tau     %time to maturity in years
        opt_business_tau
        %implied vol
        impvol
        %delta
        delta
        %gamma
        gamma
        %vega
        vega
        %theta
        theta
        %riskless rate
        riskless_rate
    end
    
    methods
        function obj = init(obj,codestr)
            [flag,optiontype,strike,underlierstr,expiry] = isoptchar(codestr);
            if flag
                obj.code_ctp = str2ctp(codestr);
                obj.code_wind = ctp2wind(obj.code_ctp);
                obj.code_bbg = ctp2bbg(obj.code_ctp);
                %
                obj.code_ctp_underlier = str2ctp(underlierstr);
                obj.code_wind_underlier = ctp2wind(obj.code_ctp_underlier);
                obj.code_bbg_underlier = ctp2bbg(obj.code_ctp_underlier);
                
                obj.opt_type = optiontype;
                if ischar(strike)
                    obj.opt_strike = str2double(strike);
                else
                    obj.opt_strike = strike;
                end
                obj.opt_expiry_date1 = expiry;
                obj.opt_expiry_date2 = datestr(expiry,'yyyy-mm-dd');
            
                obj.init_flag = true;
            else
                obj.init_flag = false;
            end
        end
        
        function obj = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_,underlier_quote_,calcgreeks)
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
                midopt = 0.5*(obj.bid1 + obj.ask1);
                r = obj.riskless_rate;
                if strcmpi(obj.opt_type,'C')
                    opttype = 'call';
                else
                    opttype = 'put';
                end
                warning('off')
                obj.impvol = bjsimpv(mid,obj.opt_strike,r,cob_date,...
                    obj.opt_expiry_date1,midopt,[],r,[],opttype);
                if isnan(obj.impvol )
                    obj.impvol = 0.01;
                end
            else
                %TODO
                error('not implemeneted')
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
                %TODO
                error('not implemeneted')
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
                %TODO
                error('not implemeneted')
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
                %TODO
                error('not implemeneted')
            end
            
        end
        %
        
        function print(obj)
            fprintf('%s ',obj.update_time2);   
            fprintf('trade:%4.1f;',obj.last_trade);
            fprintf('delta:%4.2f;',obj.delta);
            fprintf('gamma:%4.2f;',obj.gamma);
            fprintf('theta:%4.2f;',obj.theta);
            fprintf('vega:%4.2f;',obj.vega);
            fprintf('iv:%4.2f;',obj.impvol);
            fprintf('tau:%2.2f:',obj.opt_business_tau);
            fprintf('instrument:%s\n',obj.code_ctp);
                
                
                
                
        end
        
    end
    
    
    
end