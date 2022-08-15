% initial stocks - jinntao 2018/08/17
classdef cStock < cInstrument
    properties        
        code_ctp@char
        code_wind@char
        code_bbg@char
        code_H5@char
        
        contract_size@double = 100
        tick_size@double
        tick_value@double
        asset_name@char
        exchange@char
        ipo_date1@double
        ipo_date2@char
        
        trading_hours@char
        trading_break@char;      
        holidays@char

    end
    
    properties (GetAccess = public, Dependent = true)
        break_interval@cell;
    end
    
    methods
        function break_interval = get.break_interval(obj)
            nlength = length(obj.trading_hours);
            % 09:00-11:30; which length is 12
            M= round(nlength/12);
            break_interval =cell(M,2);
            for i = 1:M
                break_interval{i,1} = [obj.trading_hours(1+(i-1)*12:5+(i-1)*12),':00'];
                break_interval{i,2} = [obj.trading_hours(7+(i-1)*12:11+(i-1)*12),':00'];
            end
        end
        %
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
            if strcmpi(codestr,'000001.SH')
                obj.code_wind = codestr;
            elseif strcmpi(codestr,'SPX') || strcmpi(codestr,'DJI') || strcmpi(codestr,'IXIC') || ...
                    strcmpi(codestr,'N225') || strcmpi(codestr,'FTSE') || strcmpi(codestr,'GDAXI')
                obj.code_wind = [codestr,'.GI'];
            else
                if length(codestr) == 6
                    if strcmpi(codestr(1),'6') || strcmpi(codestr(1),'5')
                        obj.code_wind = [codestr,'.SH'];
                    else
                        obj.code_wind = [codestr,'.SZ'];
                    end
                elseif length(codestr) == 4
                    obj.code_wind = [codestr,'.HK'];
                end
            end
            if isempty(obj.code_wind) && ~isempty(strfind(obj.code_ctp,'.WI'))
                obj.code_wind = obj.code_ctp;
            end
            obj.code_bbg = 'n/a';
            obj.code_H5 = 'n/a';
            
            if strcmpi(codestr,'000001.SH')
                obj.tick_size = 0.01;
            else
                if strcmpi(codestr(1),'1') || strcmpi(codestr(1),'5')
                    obj.tick_size = 0.001;
                else
                    obj.tick_size = 0.01;
                end
            end
            
            obj.tick_value = obj.tick_size * obj.contract_size;

            obj.trading_hours = '09:30-11:30;13:00-15:00';
            obj.trading_break = '';
            obj.holidays = 'shanghai';
            if strcmpi(codestr,'SPX') || strcmpi(codestr,'DJI') || strcmpi(codestr,'IXIC')
                obj.holidays = 'new york';
                obj.trading_hours = '';
            end
            if strcmpi(codestr,'N225')
                obj.holidays = 'tokyo';
                obj.trading_hours = '';
            end
            if strcmpi(codestr,'FTSE')
                obj.holidays = 'london';
                obj.trading_hours = '';
            end
            if strcmpi(codestr,'GDAXI')
                obj.holidays = 'frankfurt';
                obj.trading_hours = '';
            end
            
        end
        %end of constructor
        
        [] = demo(obj)
        [assetname,exch] = getexchangestr(obj)
        [] = init_bbg(obj,conn)
        [] = init_wind(obj,w)
    end
        
end