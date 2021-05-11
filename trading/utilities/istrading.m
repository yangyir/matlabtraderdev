function [flag,t_trading] = istrading(t,tradingHours,varargin)
%function to window the trading time only
%input t may include time outside trading hours
%
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('t',@isnumeric);
    p.addRequired('TradingHours',@ischar);
     p.addParameter('TradingBreak',{},...
            @(x) validateattributes(x,{'char'},{},'','TradingBreak'));
    p.parse(t,tradingHours,varargin{:});
    t = p.Results.t;
    tradingHours = p.Results.TradingHours;
    tradingBreak = p.Results.TradingBreak;

    th = regexp(tradingHours,';','split');
    m = regexp(th{1},'-','split');
    a = regexp(th{2},'-','split');
    mOpen = 60*str2double(m{1}(1:2))+str2double(m{1}(end-1:end));
    mClose = 60*str2double(m{2}(1:2))+str2double(m{2}(end-1:end));
    aOpen = 60*str2double(a{1}(1:2))+str2double(a{1}(end-1:end));
    aClose = 60*str2double(a{2}(1:2))+str2double(a{2}(end-1:end));
    date = datenum(datestr(t,'dd-mmm-yyyy'));
    if ~isnumeric(t)
        t = datenum(t);
    end
    %code change:
    %time shall be before the market close time not before and on the
    %market close time
    idx_m = (t - date - mOpen/1440 > -1e-10) & (t - date < mClose/1440);
    idx_a = (t - date - aOpen/1440 > -1e-10) & (t - date < aClose/1440);
    idx = idx_m | idx_a;
    
    if length(th) == 3
        e = regexp(th{3},'-','split');
        if length(e) > 1
            e_open = 60*str2double(e{1}(1:2))+str2double(e{1}(end-1:end));
            e_close = 60*str2double(e{2}(1:2))+str2double(e{2}(end-1:end));
            if e_close > mOpen
                idx_e = (t - date >= e_open/1440) & (t - date < e_close/1440);
            else
                idx_e = (t - date >= e_open/1440) & (t - date <= 1);
                idx_e = idx_e | ((t-date>=0) & (t-date<e_close/1440));
            end
            idx = idx | idx_e;
        end
    end
    %
    if ~isempty(tradingBreak)
        tb = regexp(tradingBreak,'-','split');
        if length(tb) == 2
            tb_start = 60*str2double(tb{1}(1:2))+str2double(tb{1}(end-1:end));
            tb_end = 60*str2double(tb{2}(1:2))+str2double(tb{2}(end-1:end));
            tb_start = tb_start/1440;
            tb_end = tb_end/1440;
            idx_tb = t - date>= tb_start & t - date < tb_end;
            idx = idx & (~idx_tb);
        end
    end
    
    flag = idx;
    t_trading = t(idx,:);
%
end

