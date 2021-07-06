% initial stocks - jinntao 2018/08/17
classdef cStock < cInstrument
    properties        
        code_ctp@char
        code_wind@char
        code_bbg@char
        code_H5@char
        
        tick_size@double
        asset_name@char
        exchange@char
        ipo_date1@double
        ipo_date2@char
        
        trading_hours@char
        trading_break@char;      
        holidays@char

    end
    
    methods
        function [] = delete(obj)
            obj.code_ctp = '';
            obj.code_wind = '';
            obj.code_bbg = '';
            obj.code_H5 = '';
          
            obj.tick_size = [];
            obj.asset_name = '';
            obj.exchange = '';
            obj.ipo_date1 = [];
            obj.ipo_date2 = '';
            obj.trading_hours = '';
            obj.trading_break = '';
            
            delete@cInstrument(obj);
        end
         
        function obj = cStock(codestr)
            % check number of function input arguments
            if nargin < 1
                return
            end
            
            obj.code_ctp = codestr;
            obj.code_wind = codestr;
            obj.code_bbg = codestr;
            obj.code_H5 = codestr;
            
            if strcmpi(codestr(1),'1') || strcmpi(codestr(1),'5')
                obj.tick_size = 0.001;
            else
                obj.tick_size = 0.01;
            end

            obj.trading_hours = '09:30-11:30;13:00-15:00';
            obj.trading_break = '';      
            obj.holidays = 'shanghai';
            
        end
        %end of constructor
        
        [] = demo(obj)
        [assetname,exch] = getexchangestr(obj)
        [] = init_bbg(obj,conn)
        [] = init_wind(obj,w)
    end
        
end