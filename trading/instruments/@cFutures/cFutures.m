classdef cFutures < cInstrument
    properties
        code_ctp@char
        code_wind@char
        code_bbg@char
        contract_size@double
        tick_size@double
        tick_value@double
        asset_name@char
        exchange@char
        first_trade_date1@double
        first_trade_date2@char
        last_trade_date1@double
        last_trade_date2@char
        first_notice_date1@double
        first_notice_date2@char
        first_dlv_date1@double
        first_dlv_date2@char
        last_dlv_date1@double
        last_dlv_date2@char
        
        trading_hours@char
        trading_break@char
        
        holidays@char = 'shanghai'
        
        init_margin_rate
        
    end
    
    methods
        function [] = delete(obj)
            obj.code_ctp = '';
            obj.code_wind = '';
            obj.code_bbg = '';
            obj.contract_size = [];
            obj.tick_size = [];
            obj.tick_value = [];
            obj.asset_name = '';
            obj.exchange = '';
            obj.first_trade_date1 = [];
            obj.first_trade_date2 = '';
            obj.last_trade_date1 = [];
            obj.last_trade_date2 = '';
            obj.first_notice_date1 = [];
            obj.first_notice_date2 = '';
            obj.first_dlv_date1 = [];
            obj.first_dlv_date2 = '';
            obj.last_dlv_date1 = [];
            obj.last_dlv_date2 = '';
            obj.trading_hours = '';
            obj.trading_break = '';
            obj.init_margin_rate = [];
            delete@cInstrument(obj);
        end
        
        
        function obj = cFutures(codestr)
            if nargin < 1
                return
            end
            
            obj.code_ctp = str2ctp(codestr);
            obj.code_wind = ctp2wind(obj.code_ctp);
            obj.code_bbg = ctp2bbg(obj.code_ctp);
            
            [asset,ex] = obj.getexchangestr;
            obj.asset_name = asset;
            obj.exchange = ex;
                
        end
        %end of constructor
        
        tradingLength = trading_length(obj)        
        [] = demo(obj)
        [] = init_bbg(obj,conn)
        [assetname,exch] = getexchangestr(obj)
        
    end
    
end