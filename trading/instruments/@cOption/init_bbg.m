function obj = init_bbg(obj,conn)
    ctpstr = obj.code_ctp;
    if isempty(ctpstr)
        return
    end

    if nargin < 2, return; end

    if ~isa(conn,'blp')
        error('cOption:init:invalid bloomberg connection')
    end
    
    if strcmpi(ctpstr(1:2),'IO')
        bbg_fields = {'opt_cont_size',...
            'opt_val_pt',...
            'opt_tick_size',...
            'opt_first_trade_dt',...
            'last_tradeable_dt',...
            'exchange_trading_session_hours'};
    else
        bbg_fields = {'fut_cont_size',...
            'fut_val_pt',...
            'fut_tick_size',...
            'fut_first_trade_dt',...
            'last_tradeable_dt',...
            'exchange_trading_session_hours'};
    end
    data = getdata(conn,obj.code_bbg,bbg_fields);
    
    if ~strcmpi(ctpstr(1:2),'IO')
        obj.contract_size = data.fut_cont_size;
        obj.tick_size = data.fut_tick_size;
        obj.tick_value = obj.tick_size*obj.contract_size;
        obj.first_trade_date1 = data.fut_first_trade_dt;
    else
        obj.contract_size = data.opt_cont_size;
        obj.tick_size = data.opt_tick_size;
        obj.tick_value = obj.tick_size*obj.contract_size;
        obj.first_trade_date1 = data.opt_first_trade_dt;
        
    end
    obj.first_trade_date2 = datestr(obj.first_trade_date1,'yyyy-mm-dd');    
    obj.last_trade_date1 = data.last_tradeable_dt;
    obj.last_trade_date2 = datestr(obj.last_trade_date1,'yyyy-mm-dd');
    obj.opt_expiry_date1 = obj.last_trade_date1;
    obj.opt_expiry_date2 = obj.last_trade_date2;
    
    th = data.exchange_trading_session_hours;
    th_ = th{1};
    if size(th_,1) == 3
        obj.trading_hours = [th_{2,2},';',th_{3,2},';',th_{1,2}];
        obj.trading_break = '10:15-10:30';
    else
        if strcmpi(ctpstr(1:2),'IO')
            obj.trading_hours = '09:30-11:30;13:00-15:00';
        else
            obj.trading_hours = [th_{1,2},';',th_{2,2}];
        end
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

