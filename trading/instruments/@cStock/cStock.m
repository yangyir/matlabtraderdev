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
            if strcmpi(codestr,'000001.SH') || strcmpi(codestr,'000300.SH') || ...
                    strcmpi(codestr,'000016.SH') || strcmpi(codestr,'000905.SH') || ...
                    strcmpi(codestr,'000852.SH') || strcmpi(codestr,'399006.SZ') || ...
                    strcmpi(codestr,'000688.SH') || strcmpi(codestr,'000015.SH')
                obj.code_wind = codestr;
            elseif strcmpi(codestr,'SPX') || strcmpi(codestr,'DJI') || strcmpi(codestr,'IXIC') || ...
                    strcmpi(codestr,'N225') || strcmpi(codestr,'FTSE') || strcmpi(codestr,'GDAXI')
                obj.code_wind = [codestr,'.GI'];
            elseif strcmpi(codestr,'gzhy')
                obj.code_wind = 'TB10Y.WI';
            elseif strcmpi(codestr,'gzhy_30y')
                obj.code_wind = 'TB30Y.WI';
            elseif strcmpi(codestr,'tb01y') || strcmpi(codestr,'tb03y') || strcmpi(codestr,'tb05y') || ...
                    strcmpi(codestr,'tb07y') || strcmpi(codestr,'tb10y') || strcmpi(codestr,'tb30y')
                obj.code_wind = [upper(codestr),'.WI'];
            elseif strcmpi(codestr,'UK100') || strcmpi(codestr,'AUS200') || strcmpi(codestr,'J225') || ...
                    strcmpi(codestr,'GER30m') || strcmpi(codestr,'SPX500m') || strcmpi(codestr,'HK50')
                obj.code_wind = codestr;
                obj.asset_name = codestr;
            else
                if length(codestr) == 6 && isempty(strfind(obj.code_ctp,'.WI'))
                    if strcmpi(codestr(1),'6') || strcmpi(codestr(1),'5')
                        obj.code_wind = [codestr,'.SH'];
                    elseif strcmpi(codestr(1),'0') || strcmpi(codestr(1),'1') || strcmpi(codestr(1),'3')
                        obj.code_wind = [codestr,'.SZ'];
                    elseif strcmpi(codestr(1),'4') || strcmpi(codestr(1),'8') 
                        obj.code_wind = [codestr,'.BJ'];
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
            elseif strcmpi(codestr,'tb01y') || strcmpi(codestr,'tb03y') || strcmpi(codestr,'tb05y') || ...
                    strcmpi(codestr,'tb07y') || strcmpi(codestr,'tb10y') || strcmpi(codestr,'tb30y')
                obj.tick_size = 0.001;
            elseif strcmpi(codestr,'UK100')
                obj.contract_size = 10;%gbp
                obj.tick_size = 0.1;
            elseif strcmpi(codestr,'AUS200')
                obj.contract_size = 10;%aud
                obj.tick_size = 0.1;
            elseif strcmpi(codestr,'J225')
                obj.contract_size = 1000;%yen
                obj.tick_size = 1;
            elseif strcmpi(codestr,'GER30m')
                obj.contract_size = 10;%eur
                obj.tick_size = 0.1;
            elseif strcmpi(codestr,'SPX500m')
                obj.contract_size = 10;%usd
                obj.tick_size = 0.1;
            elseif strcmpi(codestr,'HK50')
                obj.contract_size = 10;%hkd
                obj.tick_size = 0.1;
            else
                if strcmpi(codestr(1),'1') || strcmpi(codestr(1),'5')
                    obj.tick_size = 0.001;
                elseif strcmpi(codestr,'gzhy') || strcmpi(codestr,'gzhy_30y')
                    obj.tick_size = 0.0025;
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
            if strcmpi(codestr,'UK100') || strcmpi(codestr,'AUS200') || strcmpi(codestr,'J225') || ...
                    strcmpi(codestr,'GER30m') || strcmpi(codestr,'SPX500m') || strcmpi(codestr,'HK50')
                obj.holidays = 'MT4';
                obj.trading_hours = '';
            end
            
        end
        %end of constructor
        
        [] = demo(obj)
        [assetname,exch] = getexchangestr(obj)
        [] = init_bbg(obj,conn)
        [] = init_wind(obj,w)
        [] = init_ths(obj,ths)
    end
        
end