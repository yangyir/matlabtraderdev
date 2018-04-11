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
        [] = init(obj,codestr)
        [] = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_,underlier_quote_,calcgreeks)
        [] = print(obj)

        
    end
    
    
    
end