function spread = timeseries_spread(buy,sell,varargin)

last_trade_expiry = '15:00:00';

if isempty(varargin)
    % default values
    date_from = NaN;
    date_to = NaN;
    interval = {};
    mult_buy = 1;
    mult_sell = 1;
    relative = 0;
    trading_hours_buy = {};
    trading_hours_sell = {};
    trading_break_buy = {};
    trading_break_sell = {};    
    leg_name_buy = {};
    leg_name_sell = {};
else
    parser = inputParser;
    parser.CaseSensitive = false;
    parser.KeepUnmatched = true;
    parser.addParamValue('FromDate',NaN,...
            @(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
    parser.addParamValue('ToDate',NaN,...
            @(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
    parser.addParamValue('Interval',{},...
            @(x) validateattributes(x,{'cell','char'},{},'','Interval'));
    parser.addParamValue('MultipleBuy',1,...
            @(x) validateattributes(x,{'numeric'},{},'','MultipleBuy'));
    parser.addParamValue('MultipleSell',1,...
            @(x) validateattributes(x,{'numeric'},{},'','MultipleSell'));
    parser.addParamValue('RelFlag',0,...
            @(x) validateattributes(x,{'numeric'},{},'','RelFlag'));
    parser.addParamValue('TradingHoursBuy',{},...
            @(x) validateattributes(x,{'cell','char'},{},'','TradingHoursBuy'));
    parser.addParamValue('TradingHoursSell',{},...
            @(x) validateattributes(x,{'cell','char'},{},'','TradingHoursSell'));
    parser.addParamValue('TradingBreakBuy',{},...
            @(x) validateattributes(x,{'cell','char'},{},'','TradingBreakBuy'));
    parser.addParamValue('TradingBreakSell',{},...
            @(x) validateattributes(x,{'cell','char'},{},'','TradingBreakSell'));   
    parser.addParamValue('LegNameBuy',{},...
            @(x) validateattributes(x,{'char'},{},'','LegNameBuy'));
    parser.addParamValue('LegNameSell',{},...
            @(x) validateattributes(x,{'char'},{},'','LegNameSell'));
    %
    parser.parse(varargin{:});
    date_from = parser.Results.FromDate;
    date_to = parser.Results.ToDate;
    interval = parser.Results.Interval;
    mult_buy = parser.Results.MultipleBuy;
    mult_sell = parser.Results.MultipleSell;
    relative = parser.Results.RelFlag;
    trading_hours_buy = parser.Results.TradingHoursBuy;
    trading_hours_sell = parser.Results.TradingHoursSell;
    trading_break_buy = parser.Results.TradingBreakBuy;
    trading_break_sell = parser.Results.TradingBreakSell;
    leg_name_buy = parser.Results.LegNameBuy;
    leg_name_sell = parser.Results.LegNameSell; 
end
%
buy = timeseries_window(buy,'FromDate',date_from,...
                            'ToDate',date_to,...
                            'TradingHours',trading_hours_buy,...
                            'TradingBreak',trading_break_buy);
%
sell = timeseries_window(sell,'FromDate',date_from,...
                            'ToDate',date_to,...
                            'TradingHours',trading_hours_sell,...
                            'TradingBreak',trading_break_sell);

% intersect by time
[t,ib,is] = intersect(buy(:,1),sell(:,1));
buy = buy(ib,:);
sell = sell(is,:);
if size(buy,2) > 2
    idx = 5;%column order from bloomberg output
else
    idx = 2;
end
if relative
    spread_full = [t,(mult_buy*buy(:,idx)-...
                mult_sell*sell(:,idx))./(mult_buy*buy(:,idx))];
else
    spread_full = [t,mult_buy*buy(:,idx)-mult_sell*sell(:,idx)];
end
%
% remove NaNs from leg data
spread_window = spread_full(~isnan(spread_full(:,2)),:);

%
intraday_flag = sum(hour(t)+minute(t)) > 0;
if intraday_flag && ~(isempty(leg_name_buy) && isempty(leg_name_sell))
    if isempty(leg_name_buy)
        leg_name_buy = '';
    end
    if isempty(leg_name_sell)
        leg_name_sell = '';
    end
    % to exclude the data happened after the last trade on expiry
    expiry_flag = zeros(size(spread_window,1),1);
    if strcmpi(leg_name_buy,'300') || strcmpi(leg_name_buy,'50') || strcmpi(leg_name_buy,'500') || ...
       strcmpi(leg_name_sell,'300') || strcmpi(leg_name_sell,'50') || strcmpi(leg_name_sell,'500')
        t_d = datenum(datestr(spread_window(:,1),'dd-mmm-yyyy'));
        t_expiry_buy = get_expiries_next(t_d,leg_name_buy);
        t_expiry_sell = get_expiries_next(t_d,leg_name_sell);
        expiry_flag = t_expiry_buy == t_d | t_expiry_sell == t_d;
    end
        t_h = hour(spread_window(:,1));
        t_m = minute(spread_window(:,1));
        use_flag = ones(size(spread_window,1),1);
        for i = 1:length(use_flag)
            if expiry_flag(i) && t_h(i) >= hour(last_trade_expiry) ...
                    && t_m(i) > minute(last_trade_expiry)
                use_flag(i) = 0;
            end
        end
        idx = use_flag == 1;
        spread_window = spread_window(idx,:);
end

spread = timeseries_compress(spread_window,'Interval',interval);

end