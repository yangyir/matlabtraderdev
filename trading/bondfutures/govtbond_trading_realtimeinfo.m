function output = govtbond_trading_realtimeinfo(conn,rollinfo5y,rollinfo10y,varargin)
if ~isa(conn,'blp')
    error('govtbond_trading_realtimeinfo:missing bloomberg connection');
end

if nargin > 3
    doPrint = varargin{1};
else
    doPrint = true;
end

lastbd = rollinfo5y.ContinousFutures(end,1);
pxCloseYst5y = rollinfo5y.ContinousFutures(end,2);
windCode5y = rollinfo5y.RollInfo{end,5};
contract5y = windcode2contract(windCode5y(1:length(windCode5y)-4));
%
pxCloseYst10y = rollinfo10y.ContinousFutures(end,2);
windCode10y = rollinfo10y.RollInfo{end,5};
contract10y = windcode2contract(windCode10y(1:length(windCode10y)-4));
%get real-time price information
data = getdata(conn,{contract5y.BloombergCode,contract10y.BloombergCode},'last_trade');
pxLastTrade5y = data.last_trade(1);
pxLastTrade10y = data.last_trade(2);
%
%compute the synthetic implied yield
yldCloseYst5y = bndyield(pxCloseYst5y,0.03,lastbd,dateadd(lastbd,'5y'));
yldCloseYst10y = bndyield(pxCloseYst10y,0.03,lastbd,dateadd(lastbd,'10y'));
yldLastTrade5y = bndyield(pxLastTrade5y,0.03,today,dateadd(today,'5y'));
yldLastTrade10y = bndyield(pxLastTrade10y,0.03,today,dateadd(today,'10y'));
%
%compute durations
mdLastTrade5y = bnddurp(pxLastTrade5y,0.03,today,dateadd(today,'5y'));
mdLastTrade10y = bnddurp(pxLastTrade10y,0.03,today,dateadd(today,'10y'));
%
%compute the 5-10 yield curve slope change as of the 10y change - 5y change
slopeChg = (yldLastTrade10y-yldCloseYst10y)-(yldLastTrade5y-yldCloseYst5y);
slopeChg = slopeChg*10000;
updateTime = now;

if doPrint
    fprintf('\n')
    fprintf('update time:%s\n',datestr(updateTime));
    fprintf('\tCN govtbond %2dy futs-->>',5);
    fprintf(';last trade:%4.3f',pxLastTrade5y);
    fprintf(';px chg:%4.3f',pxLastTrade5y-pxCloseYst5y);
    fprintf(';yld:%4.2f%%',yldLastTrade5y*100);
    fprintf(';yld chg(bp):%4.1f',(yldLastTrade5y-yldCloseYst5y)*10000);
    fprintf(';duration:%4.1f\n',mdLastTrade5y);
    %
    fprintf('\tCN govtbond %2dy futs-->>',10);
    fprintf(';last trade:%4.3f',pxLastTrade10y);
    fprintf(';px chg:%4.3f',pxLastTrade10y-pxCloseYst10y);
    fprintf(';yld:%4.2f%%',yldLastTrade10y*100);
    fprintf(';yld chg(bp):%4.1f',(yldLastTrade10y-yldCloseYst10y)*10000);
    fprintf(';duration:%4.1f\n',mdLastTrade10y);

    fprintf('\tyld curve slope(bp):%4.1f\n',(yldLastTrade10y-yldLastTrade5y)*1e4);
    fprintf('\tyld curve slope chg(bp):%4.1f\n',slopeChg);
end
%
%construct output
output = struct('UpdateTime',updateTime,...
    'LastBusinessDate',lastbd,...
    'PxLastTrade',[pxLastTrade5y,pxLastTrade10y],...
    'PxCloseYst',[pxCloseYst5y,pxCloseYst10y],...
    'YldLastTrade',[yldLastTrade5y,yldLastTrade10y],...
    'YldCloseYst',[yldCloseYst5y,yldCloseYst10y],...
    'YldSlopeChg',slopeChg);

end

