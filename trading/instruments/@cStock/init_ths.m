function [] = init_ths(obj,ths)
%cStock methods
    ctpstr = obj.code_wind;
    if isempty(ctpstr)
        return
    end

    if nargin < 2, return; end

    if ~isa(ths,'cTHS')
        error('cFutures:init_ths:invalid THS connection')
    end
    
%     ths_fields = {'ths_etf_listed_date_fund';...
%         'ths_fund_short_name_fund';...
%         'ths_fund_listed_exchange_fund'};
%     
    ths_data = THS_BD(obj.code_wind,'ths_fund_short_name_fund','','format:table');
    obj.asset_name = ths_data.ths_fund_short_name_fund{1};
    %
    ths_data = THS_BD(obj.code_wind,'ths_fund_listed_exchange_fund','','format:table');
    obj.exchange = ths_data.ths_fund_listed_exchange_fund{1};
    %
    ths_data = THS_BD(obj.code_wind,'ths_etf_listed_date_fund','','format:table');
    obj.ipo_date1 = datenum(ths_data.ths_etf_listed_date_fund{1},'yyyymmdd');
    obj.ipo_date2 = datestr(obj.ipo_date1,'yyyy-mm-dd');
    
end
%end of init_ths
