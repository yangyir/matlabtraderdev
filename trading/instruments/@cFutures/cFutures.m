classdef cFutures < cInstrument
    properties
        % instrument 
        code_ctp
        code_wind
        code_bbg
        code_H5
        
        
        contract_size
        tick_size
        tick_value
        asset_name
        exchange
        first_trade_date1
        first_trade_date2
        last_trade_date1
        last_trade_date2
        first_notice_date1
        first_notice_date2
        first_dlv_date1
        first_dlv_date2
        last_dlv_date1
        last_dlv_date2
        
        trading_hours
        trading_break
        
        holidays = 'shanghai'
        
        init_margin_rate
        
    end
    
    properties (GetAccess = public, Dependent = true)
        break_interval;
%         opening_time@char;
    end
    
    methods
        
%         function [] = set.code_H5(obj, vin)
%             
%             if iscell(vin), vin = vin{1}; end
%             
%             cl = class(vin);
%             switch cl
%                 case {'double' }
%                     % disp('强制类型转换：cInstrument.code_H5应为char');
%                     vout = num2str(vin);                    
%                 case {'char'}
%                     vout = vin;
%                 otherwise
%                     warning('赋值失败：ocInstrument.code_H5应为char');
%                     return;
%             end
%             obj.code_H5 = vout;
%         end
        
        
        function break_interval = get.break_interval(obj)
           nlength = length(obj.trading_hours);
           % 09:00-11:30; which length is 12
               if length(obj.trading_break)<3
                   M= round(nlength/12);
                   break_interval =cell(M,2);
                   for i = 1:M
                       break_interval{i,1} = [obj.trading_hours(1+(i-1)*12:5+(i-1)*12),':00'];
                       break_interval{i,2} = [obj.trading_hours(7+(i-1)*12:11+(i-1)*12),':00'];
                   end
               else
                   nlength2 = length(obj.trading_break);
                   M1 = round(nlength/12);
                   M2 = round(nlength2/12);
                   break_interval = cell(M1+M2,2);
                   for i =1:(M1+M2)
                       if i ==1
                           break_interval{i,1} = [obj.trading_hours(1:5),':00'];
                           break_interval{i,2} = [obj.trading_break(1:5),':00'];
                       elseif i ==2
                           break_interval{i,1} = [obj.trading_break(7:11),':00'];
                           break_interval{i,2} = [obj.trading_hours(7:11),':00'];
                       else
                           break_interval{i,1} = [obj.trading_hours(1+(i-2)*12:5+(i-2)*12),':00'];
                           break_interval{i,2} = [obj.trading_hours(7+(i-2)*12:11+(i-2)*12),':00'];
                       end
                   end
               end
        end
        
%         function opening_time = get.opening_time(obj)
%             if length(obj.trading_break)<3
%                 opening_time = [obj.trading_hours(1:5),':00'];
%             else
%                 opening_time = [obj.trading_hours(end-10:end-6),':00'];
%             end
%         end
        
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
            obj.code_H5 = codestr;
            
            
            [asset,ex] = obj.getexchangestr;
            obj.asset_name = asset;
            obj.exchange = ex;
                
        end
        %end of constructor
        
        tradingLength = trading_length(obj)        
        [] = demo(obj)
        [] = init_bbg(obj,conn)
        [] = init_wind(obj,w)
        [] = init_ths(obj,ths)
        [assetname,exch] = getexchangestr(obj)
        [ret] = isable2trade(obj,t)
        
    end
    
end