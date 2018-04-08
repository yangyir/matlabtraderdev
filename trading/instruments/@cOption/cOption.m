classdef cOption < cInstrument
    properties
        code_ctp@char
        code_wind@char
        code_bbg@char
        code_ctp_underlier@char
        code_wind_underlier@char
        code_bbg_underlier@char
        
        opt_american@double
        opt_type@char
        opt_strike@double
        opt_expiry_date1@double
        opt_expiry_date2@char
        
        contract_size@double
        tick_size@double
        tick_value@double
        asset_name@char
        exchange@char
        first_trade_date1@double
        first_trade_date2@char
        last_trade_date1@double
        last_trade_date2@char
        
        trading_hours@char
        trading_break@char
        
        holidays = 'shanghai'
        
        
    end
    
    methods
        function [] = delete(obj)
            obj.code_ctp = '';
            obj.code_wind = '';
            obj.code_bbg = '';
            obj.code_ctp_underlier = '';
            obj.code_wind_underlier = '';
            obj.code_bbg_underlier = '';
            obj.opt_american = [];
            obj.opt_type = '';
            obj.opt_strike =[];
            obj.opt_expiry_date1 =[];
            obj.opt_expiry_date2 = '';
            obj.contract_size =[];
            obj.tick_size = [];
            obj.tick_value = [];
            obj.asset_name = '';
            obj.exchange = '';
            obj.first_trade_date1 = [];
            obj.first_trade_date2 = '';
            obj.last_trade_date1 = [];
            obj.last_trade_date2 = '';
            obj.trading_hours = '';
            obj.trading_break = '';
            
            delete@cInstrument(obj);
        end
        
        function obj = cOption(codestr)
            if nargin < 1
                return
            end
            
            [flag,type,strike,underlierstr,expiry] = isoptchar(codestr);
            if ~flag
                error('cOption:invalid string input')
            end
            obj.opt_type = type;
            obj.opt_strike = strike;
            obj.code_ctp_underlier = underlierstr;
            obj.code_wind_underlier = ctp2wind(obj.code_ctp_underlier);
            obj.code_bbg_underlier = ctp2bbg(obj.code_ctp_underlier);
            obj.opt_expiry_date1 = expiry;
            obj.opt_expiry_date2 = datestr(obj.opt_expiry_date1,'yyyy-mm-dd');
            
            obj.code_ctp = str2ctp(codestr);
            obj.code_wind = ctp2wind(obj.code_ctp);
            obj.code_bbg = ctp2bbg(obj.code_ctp);
            
            [asset,ex] = obj.getexchangestr;
            obj.asset_name = asset;
            obj.exchange = ex;
            
            if strcmpi(obj.exchange,'.DCE') || strcmpi(obj.exchange,'.CZC')
                obj.opt_american = 1;
            else
                obj.opt_american = 0;
            end
            
        end
        %end of constructor
        
        [] = demo(obj)
        [] = init_bbg(obj,conn)
        [assetname,exch] = getexchangestr(obj)
        
    end
        
end