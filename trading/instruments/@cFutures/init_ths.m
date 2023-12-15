function [] = init_ths(obj,ths)
    ctpstr = obj.code_ctp;
    if isempty(ctpstr)
        return
    end

    if nargin < 2, return; end

    if ~isa(ths,'cTHS')
        error('cFutures:init_ths:invalid THS connection')
    end
    
%     ths_fields = {'ths_contract_multiplier_future';...
%         'ths_mini_chg_price_future';...
%         'ths_start_trade_date_future';...
%         'ths_last_td_date_future';...
%         'ths_last_delivery_date_future';...
%         'ths_initial_td_deposit_future';...
%         'ths_open_time_day_future';...
%         'ths_close_time_am_future';...
%         'ths_open_time_pm_future';...
%         'ths_close_time_day_future';...
%         'ths_open_time_night_future';...
%         'ths_close_time_night_future';...
%         'ths_rest_start_time_future';...
%         'ths_rest_end_time_future'};
    reverseflag = false;
    if ~isempty(strfind(obj.code_wind,'.INE'))
        obj.code_wind = [obj.code_wind(1:end-4),'.SHF'];
        reverseflag = true;
    end
    
    ths_data = THS_BD(obj.code_wind,'ths_contract_multiplier_future','','format:table');
    obj.contract_size = ths_data.ths_contract_multiplier_future;
    %
    ths_data = THS_BD(obj.code_wind,'ths_mini_chg_price_future','','format:table');
    obj.tick_size = ths_data.ths_mini_chg_price_future;
    %
    obj.tick_value = obj.contract_size*obj.tick_size;
    %
    ths_data = THS_BD(obj.code_wind,'ths_start_trade_date_future','','format:table');
    obj.first_trade_date1 = datenum(ths_data.ths_start_trade_date_future,'yyyymmdd');
    obj.first_trade_date2 = datestr(obj.first_trade_date1,'yyyy-mm-dd');
    %
    ths_data = THS_BD(obj.code_wind,'ths_last_td_date_future','','format:table');
    obj.last_trade_date1 = datenum(ths_data.ths_last_td_date_future,'yyyymmdd');
    obj.last_trade_date2 = datestr(obj.last_trade_date1,'yyyy-mm-dd');
    %
    obj.first_notice_date1 = obj.last_trade_date1;
    obj.first_notice_date2 = datestr(obj.first_notice_date1,'yyyy-mm-dd');
    %
    obj.first_dlv_date1 = dateadd(obj.last_trade_date1,'1b');
    obj.first_dlv_date2 = datestr(obj.first_dlv_date1,'yyyy-mm-dd');
    %
    ths_data = THS_BD(obj.code_wind,'ths_last_delivery_date_future','','format:table');
    try
        obj.last_dlv_date1 = datenum(ths_data.ths_last_delivery_date_future,'yyyymmdd');
    catch
        obj.last_dlv_date1 = dateadd(obj.first_dlv_date1,'1b');
    end
    obj.last_dlv_date2 = datestr(obj.last_dlv_date1,'yyyy-mm-dd');
    %
    ths_data = THS_BD(obj.code_wind,'ths_initial_td_deposit_future','','format:table');
    obj.init_margin_rate = ths_data.ths_initial_td_deposit_future/100;
    %
    ths_data = THS_BD(obj.code_wind,'ths_open_time_day_future','','format:table');
    open_am_cell = ths_data.ths_open_time_day_future;
    ths_data = THS_BD(obj.code_wind,'ths_close_time_am_future','','format:table');
    close_am_cell = ths_data.ths_close_time_am_future;
    ths_data = THS_BD(obj.code_wind,'ths_open_time_pm_future','','format:table');
    open_pm_cell = ths_data.ths_open_time_pm_future;
    ths_data = THS_BD(obj.code_wind,'ths_close_time_day_future','','format:table');
    close_pm_cell = ths_data.ths_close_time_day_future;
    %
    ths_data = THS_BD(obj.code_wind,'ths_open_time_night_future','','format:table');
    open_night_cell = ths_data.ths_open_time_night_future;
    ths_data = THS_BD(obj.code_wind,'ths_close_time_night_future','','format:table');
    close_night_cell = ths_data.ths_close_time_night_future;
    %
    if ~isempty(open_night_cell{1})
        obj.trading_hours = [open_am_cell{1}(1:5),'-',close_am_cell{1}(1:5),';',...
            open_pm_cell{1}(1:5),'-',close_pm_cell{1}(1:5),';'...
            open_night_cell{1}(1:5),'-',close_night_cell{1}(1:5)];
    else
        obj.trading_hours = [open_am_cell{1}(1:5),'-',close_am_cell{1}(1:5),';',...
            open_pm_cell{1}(1:5),'-',close_pm_cell{1}(1:5)];
    end
    %
    ths_data = THS_BD(obj.code_wind,'ths_rest_start_time_future','','format:table');
    rest_start_cell = ths_data.ths_rest_start_time_future;
    ths_data = THS_BD(obj.code_wind,'ths_rest_end_time_future','','format:table');
    rest_end_cell = ths_data.ths_rest_end_time_future;
    obj.trading_break = [rest_start_cell{1}(1:5),'-',rest_end_cell{1}(1:5)];
    
    if reverseflag
        obj.code_wind = [obj.code_wind(1:end-4),'.INE'];
    end
    
end
%end of init_ths
