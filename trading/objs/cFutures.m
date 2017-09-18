classdef cFutures < cInstrument
    properties
        code_ctp@char
        code_wind@char
        code_bbg@char
        contract_size
        tick_size
        tick_value
        asset_name
        exchange
        first_trade_date1
        first_trade_date2@char
        last_trade_date1
        last_trade_date2@char
        first_notice_date1
        first_notice_date2@char
        first_dlv_date1
        first_dlv_date2@char
        last_dlv_date1
        last_dlv_date2@char
        
        trading_hours@char
        trading_break@char
        
        holidays = 'shanghai'
        
        init_margin_rate
        
    end
    
    methods
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
        
        function [] = init(obj,ds_)
            if isa(ds_,'cBloomberg')
                init_bbg(obj,ds_.ds_);
            else
                info = class(ds_);
                error(['cFutures:init:not implemented for class ',info])
            end          
        end
        %end of init
        
        function saveinfo(obj,fn_)
            fid = fopen(fn_,'w');
            fields = properties(obj);
            for i = 1:size(fields,1)
                propname = fields{i};
                propvalue = obj.(fields{i});
                if isnumeric(propvalue)
                    fprintf(fid,'%s\t%s\n',propname,num2str(propvalue));
                else
                    fprintf(fid,'%s\t%s\n',propname,propvalue);
                end
            end
            fclose(fid);
        end
        %end of saveinfo
        
        function [] = loadinfo(obj,fn_)
            fid = fopen(fn_,'r');
            if fid < 0
                return
            end
            line_ = fgetl(fid);
            while ischar(line_)
                lineinfo = regexp(line_,'\t','split');
                propname = lineinfo{1};
                propvalue = lineinfo{2};
                propvalue_num = str2double(propvalue);
                if isnan(propvalue_num)
                    obj.(propname) = propvalue;
                else
                    obj.(propname) = propvalue_num;
                end
                line_ = fgetl(fid);
            end
            
            fclose(fid);
        end
        %end of loadinfo
        
        function dispinfo(obj)
            disp(obj);
        end
        
        function tradingLength = trading_length(obj)
            %this function calculate how many minutes does the futures
            %trade in a day. This will help to scale the volatility from
            %daily to different time intevals
            tradingHours = regexp(obj.trading_hours,';','split');
            
            tradingLength = 0;
            for i = 1:length(tradingHours)
                mktOpenStr = tradingHours{i}(1:5);
                mktCloseStr = tradingHours{i}(end-4:end);
                mktOpenMin = str2double(mktOpenStr(1:2))*60+...
                    str2double(mktOpenStr(end-1:end));
                mktCloseMin = str2double(mktCloseStr(1:2))*60+...
                    str2double(mktCloseStr(end-1:end));
                if mktCloseMin < mktOpenMin
                    tradingLength = tradingLength + 1440-mktOpenMin + mktCloseMin;
                else
                    tradingLength = tradingLength + mktCloseMin-mktOpenMin;
                end
            end
            
            if ~isempty(obj.trading_break)
                tradingLength = tradingLength - 15;
            end
        end
        %end of trading_length
        
    end
    
    methods (Access = private)
        function [assetname,exch] = getexchangestr(obj)
            ctpstr = obj.code_ctp;
            if isempty(ctpstr)
                assetname = '';
                exch = '';
                return
            end
            
            for i = 1:length(ctpstr)
                if isnumchar(ctpstr(i)), break; end
            end
            idx = i-1;
            assetshortcode = ctpstr(1:idx);
            [assetlist,~,~,codelist,exlist]=getassetmaptable;
            for i = 1:size(codelist)
                if strcmpi(assetshortcode,codelist{i})
                    assetname = assetlist{i};
                    exch = exlist{i};
                    return
                end
            end
            exch = 'unknown';
        end
        %end of getexchangestr
        
        function [] = init_bbg(obj,conn)
            ctpstr = obj.code_ctp;
            if isempty(ctpstr)
                return
            end
            
            if nargin < 2, return; end
            
            if ~isa(conn,'blp')
                error('cFutures:init:invalid bloomberg connection')
            end
            
            bbg_fields = {'fut_cont_size',...
                'fut_val_pt',...
                'fut_tick_size',...
                'fut_tick_val',...
                'fut_first_trade_dt',...
                'last_tradeable_dt',...
                'fut_notice_first',...
                'fut_dlv_dt_first',...
                'fut_dlv_dt_last',...
                'exchange_trading_session_hours',...
                'fut_init_spec_ml',...
                'last_trade'};
            data = getdata(conn,obj.code_bbg,bbg_fields);
            
            obj.contract_size = data.fut_cont_size;
            obj.tick_size = data.fut_tick_size;
            obj.tick_value = data.fut_tick_val;
        
            obj.first_trade_date1 = data.fut_first_trade_dt;
            obj.first_trade_date2 = datestr(obj.first_trade_date1,'yyyy-mm-dd');
            obj.last_trade_date1 = data.last_tradeable_dt;
            obj.last_trade_date2 = datestr(obj.last_trade_date1,'yyyy-mm-dd');
            
            th = data.exchange_trading_session_hours;
            th_ = th{1};
            if size(th_,1) == 3
                obj.trading_hours = [th_{2,2},';',th_{3,2},';',th_{1,2}];
                obj.trading_break = '10:15-10:30';
            else
                obj.trading_hours = [th_{1,2},';',th_{2,2}];
                if strcmpi(obj.asset_name,'eqindex_300') || ...
                        strcmpi(obj.asset_name,'eqindex_50') || ...
                        strcmpi(obj.asset_name,'eqindex_500') || ...
                        strcmpi(obj.asset_name,'govtbond_5y') || ...
                        strcmpi(obj.asset_name,'govtbond_10y')
                    obj.trading_break = '';
                else
                    obj.trading_break = '10:15-10:30';
                end
            end
            
            obj.first_notice_date1 = data.fut_notice_first;
            obj.first_notice_date2 = datestr(obj.first_notice_date1,'yyyy-mm-dd');
            obj.first_dlv_date1 = data.fut_dlv_dt_first;
            obj.first_dlv_date2 = datestr(obj.first_dlv_date1,'yyyy-mm-dd');
            obj.last_dlv_date1 = data.fut_dlv_dt_last;
            obj.last_dlv_date2 = datestr(obj.last_dlv_date1,'yyyy-mm-dd');
            
            try
                obj.init_margin_rate = data.fut_init_spec_ml/(data.last_trade)/obj.contract_size;
            catch
                obj.init_margin_rate = [];
            end
            
            if strcmpi(obj.asset_name,'govtbond_5y') || strcmpi(obj.asset_name,'govtbond_10y')
                obj.init_margin_rate = obj.init_margin_rate*100;
            end
        end
        %end of init_bbg
        
    end
end