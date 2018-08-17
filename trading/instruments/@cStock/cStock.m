% initial stocks - jinntao 2018/08/17
classdef cStock < cInstrument
    properties
        code_ctp@char
        code_wind@char
        code_bbg@char
        
        code_H5@char
        
        quoteTime;%     ����ʱ��(s)
        preClose;
        preSettle;
        open; %���̼�	
        high; %��߼�	
        low;  %��ͼ�	
        last; %���¼�	
        close;%���̼�	

        bidQ1;%������1	
        bidP1;%�����1	
        bidQ2;%������2	
        bidP2;%�����2
        bidQ3;%������3	
        bidP3;%�����3	
        bidQ4;%������4	
        bidP4;%�����4	
        bidQ5;%������5	
        bidP5;%�����5	
        askQ1;%������1	
        askP1;%������1	
        askQ2;%������2	
        askP2;%������2	
        askQ3;%������3	
        askP3;%������3	
        askQ4;%������4	
        askP4;%������4	
        askQ5;%������5	
        askP5;%������5	
        volume = 0; %�ۼƳɽ�����	
        amount;     %�ۼƳɽ����	
        %        rtflag;%��Ʒʵʱ�׶α�־	
        %        mktTime;%�г�ʱ��(0.01s)
        diffVolume; %�ۼƳɽ�����������
        diffAmount; %�ۼƳɽ���������    
        
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
        % ǿ������ת��������code����char
        function [obj] = set.code_H5(obj, vin)
            % ǿ������ת��������code����char
            if iscell(vin), vin = vin{1}; end
            
            cl = class(vin);
            switch cl
                case {'double' }
                    % disp('ǿ������ת����cInstrument.code_H5ӦΪchar');
                    vout = num2str(vin);                    
                case {'char'}
                    vout = vin;
                otherwise
                    warning('��ֵʧ�ܣ�ocInstrument.code_H5ӦΪchar');
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