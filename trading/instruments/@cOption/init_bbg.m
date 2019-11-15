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
    
    obj.opt_expiry_date1 = obj.last_trade_date1;
    obj.opt_expiry_date2 = obj.last_trade_date2;

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

