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
        
        function obj = init(obj,ds_)
            if isa(ds_,'cBloomberg')
                obj = init_bbg(obj,ds_.ds_);
            else
                info = class(ds_);
                error(['cOption:init:not implemented for class ',info])
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
        
        function obj = loadinfo(obj,fn_)
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
        %end of dispinfo
        
    end
    
    methods (Access = private)
        function [assetname,exch] = getexchangestr(obj)
            ctpstr = obj.code_ctp_underlier;
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
        
        function obj = init_bbg(obj,conn)
            ctpstr = obj.code_ctp;
            if isempty(ctpstr)
                return
            end
            
            if nargin < 2, return; end
            
            if ~isa(conn,'blp')
                error('cOption:init:invalid bloomberg connection')
            end
            
            bbg_fields = {'fut_cont_size',...
                'fut_val_pt',...
                'fut_tick_size',...
                'fut_first_trade_dt',...
                'last_tradeable_dt',...
                'exchange_trading_session_hours'};
            data = getdata(conn,obj.code_bbg,bbg_fields);
            
            obj.contract_size = data.fut_cont_size;
            obj.tick_size = data.fut_tick_size;
            obj.tick_value = obj.tick_size*obj.contract_size;
        
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
            
            if strcmpi(obj.exchange,'.DCE') || strcmpi(obj.exchange,'.CZC')
                obj.opt_american = 1;
            else
                obj.opt_american = 0;
            end
            
        end
        %end of init_bbg
        
    end
    
end