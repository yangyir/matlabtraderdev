function [unwindedtrade] = charlotte_backtest_trade(varargin)
%function to give the backtest performance of a particular trade
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('trade',{},@(x) validateattributes(x,{'cTradeOpen'},{},'','trade'));
p.addParameter('usefractalupdate',0,@isnumeric);
p.addParameter('usefibonacci',1,@isnumeric);
p.parse(varargin{:});
trade = p.Results.trade;
usefracalupdateflag = p.Results.usefractalupdate;
usefibonacciflag = p.Results.usefibonacci;

trade.riskmanager_.setusefractalupdateflag(usefracalupdateflag);
trade.riskmanager_.setusefibonacciflag(usefibonacciflag);
code = trade.instrument_.code_ctp;
freq = trade.opensignal_.frequency_;

datastruct = charlotte_plot('futcode',code,'frequency',freq,'doplot',false);

openidx = trade.id_;
np = size(datastruct.px,1);

% assetname = trade.instrument_.asset_name;

for i = openidx:np
    ei_i = fractal_truncate(datastruct,i);
    if i == np
        ei_i.latestopen = ei_i.px(end,5);
        ei_i.latestdt = ei_i.px(end,1);
    else
        ei_i.latestopen = datastruct.px(i+1,2);
        ei_i.latestdt = datastruct.px(i+1,1);
    end
    
    runriskmanagementb4mktclose = false;
    
    if trade.oneminb4close1_ == 914
        %govtbond
        if strcmpi(freq,'30m')
            if strcmpi(trade.instrument_.break_interval{1,1},'09:15:00')
                if hour(ei_i.px(end,1)) == 14 && minute(ei_i.px(end,1)) == 45, runriskmanagementb4mktclose = true;end
            else
                if hour(ei_i.px(end,1)) == 15, runriskmanagementb4mktclose = true;end
            end
        elseif strcmpi(freq,'15m')
            if hour(ei_i.px(end,1)) == 15, runriskmanagementb4mktclose = true;end
        elseif strcmpi(freq,'5m')
            if hour(ei_i.px(end,1)) == 15 && minute(ei_i.px(end,1)) == 10, runriskmanagementb4mktclose = true;end
        end
    elseif trade.oneminb4close1_ == 899 && isnan(trade.oneminb4close2_)
        if ~strcmpi(freq,'30m'), error('charlotte_backtest_trade:invalid freq input....');end
        if hour(ei_i.px(end,1)) == 14 && minute(ei_i.px(end,1)) == 30, runriskmanagementb4mktclose = true;end
    elseif trade.oneminb4close1_ == 899 && trade.oneminb4close2_ == 1379
        if ~strcmpi(freq,'30m'), error('charlotte_backtest_trade:invalid freq input....');end
        if (hour(ei_i.px(end,1)) == 14 && minute(ei_i.px(end,1)) == 30) || ...
                (hour(ei_i.px(end,1)) == 22 && minute(ei_i.px(end,1)) == 30)
            runriskmanagementb4mktclose = true;
        end
    elseif trade.oneminb4close1_ == 899 && trade.oneminb4close2_ == 59
        if ~strcmpi(freq,'30m'), error('charlotte_backtest_trade:invalid freq input....');end
        if (hour(ei_i.px(end,1)) == 14 && minute(ei_i.px(end,1)) == 30) || ...
                (hour(ei_i.px(end,1)) == 0 && minute(ei_i.px(end,1)) == 30)
            runriskmanagementb4mktclose = true;
        end
    elseif trade.oneminb4close1_ == 899 && trade.oneminb4close2_ == 149
        if ~strcmpi(freq,'30m'), error('charlotte_backtest_trade:invalid freq input....');end
        if (hour(ei_i.px(end,1)) == 14 && minute(ei_i.px(end,1)) == 30) || ...
                (hour(ei_i.px(end,1)) == 2 && minute(ei_i.px(end,1)) == 30)
            runriskmanagementb4mktclose = true;
        end
    end
    
    unwindedtrade = trade.riskmanager_.riskmanagementwithcandle([],...
        'usecandlelastonly',false,...
        'debug',false,...
        'updatepnlforclosedtrade',true,...
        'extrainfo',ei_i,...
        'RunRiskManagementBeforeMktClose',runriskmanagementb4mktclose);
    
    if ~isempty(unwindedtrade)
        unwindedtrade.status_ = 'closed';
        return
    else
        if i == np && isempty(unwindedtrade)
            unwindedtrade = trade;
            unwindedtrade.status_ = 'closed';
            unwindedtrade.riskmanager_.status_ = 'closed';
            unwindedtrade.closeprice_ = ei_i.px(end,5);
            unwindedtrade.closedatetime1_ = ei_i.px(end,1);
            unwindedtrade.closepnl_ = unwindedtrade.runningpnl_;
            unwindedtrade.runningpnl_ = 0;
            unwindedtrade.riskmanager_.closestr_ = 'timeseries limit reached'; 
        end
    end
    
end

end