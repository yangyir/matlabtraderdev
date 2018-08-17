% initial stocks - jinntao 2018/08/17
classdef cStock < cInstrument
    properties
        code_ctp@char
        code_wind@char
        code_bbg@char
        
        code_H5@char
        
        quoteTime;%     行情时间(s)
        preClose;
        preSettle;
        open; %开盘价	
        high; %最高价	
        low;  %最低价	
        last; %最新价	
        close;%收盘价	

        bidQ1;%申买量1	
        bidP1;%申买价1	
        bidQ2;%申买量2	
        bidP2;%申买价2
        bidQ3;%申买量3	
        bidP3;%申买价3	
        bidQ4;%申买量4	
        bidP4;%申买价4	
        bidQ5;%申买量5	
        bidP5;%申买价5	
        askQ1;%申卖量1	
        askP1;%申卖价1	
        askQ2;%申卖量2	
        askP2;%申卖价2	
        askQ3;%申卖量3	
        askP3;%申卖价3	
        askQ4;%申卖量4	
        askP4;%申卖价4	
        askQ5;%申卖量5	
        askP5;%申卖价5	
        volume = 0; %累计成交数量	
        amount;     %累计成交金额	
        %        rtflag;%产品实时阶段标志	
        %        mktTime;%市场时间(0.01s)
        diffVolume; %累计成交数量的增量
        diffAmount; %累计成交金额的增量    
        
        code_ctp_underlier@char
        code_wind_underlier@char
        code_bbg_underlier@char

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
            obj.code_H5 = '';
            obj.code_ctp_underlier = '';
            obj.code_wind_underlier = '';
            obj.code_bbg_underlier = '';
          
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
        % 强制类型转换：所有code都是char
        function [obj] = set.code_H5(obj, vin)
            % 强制类型转换：所有code都是char
            if iscell(vin), vin = vin{1}; end
            
            cl = class(vin);
            switch cl
                case {'double' }
                    % disp('强制类型转换：cInstrument.code_H5应为char');
                    vout = num2str(vin);                    
                case {'char'}
                    vout = vin;
                otherwise
                    warning('赋值失败：ocInstrument.code_H5应为char');
                    return;
            end
            obj.code_H5 = vout;
        end
        
        function obj = cStock(codestr)
            % check number of function input arguments
            if nargin < 1
                return
            end

            %obj.code_ctp_underlier = underlierstr;
            %obj.code_wind_underlier = ctp2wind(obj.code_ctp_underlier);
            %obj.code_bbg_underlier = ctp2bbg(obj.code_ctp_underlier);

            obj.code_ctp = codestr;
            obj.code_wind = codestr;
            obj.code_bbg = codestr;
            obj.code_H5 = codestr;
            
            [asset,ex] = obj.getexchangestr;
            obj.asset_name = asset;
            obj.exchange = ex;

        end
        %end of constructor
        
        [] = demo(obj)
        [assetname,exch] = getexchangestr(obj)
        [] = init_bbg(obj,conn)
    end
        
end