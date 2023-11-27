function [] = loadtrades(mdefx,varargin)
%cmdefx
    %here path is hard-coded for the time being
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    
    t = p.Results.Time;
    wday = weekday(t);
    %find the previous weekday, regardless of any holiday calendar as fx is
    %traded worldwide
    if wday >= 3 && wday <= 7
        fn = ['bookfx_trades_',datestr(floor(t)-1,'yyyymmdd'),'.txt'];
    elseif wday == 2
        fn = ['bookfx_trades_',datestr(floor(t)-3,'yyyymmdd'),'.txt'];
    elseif wday == 1
        fn = ['bookfx_trades_',datestr(floor(t)-2,'yyyymmdd'),'.txt'];
    end
    %
    trades = cTradeOpenArray;
    trades.fromtxt2([mdefx.trades_dir_,fn]);
    %
    mdefx.trades_fx_ = trades;
        
end

