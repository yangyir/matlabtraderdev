function output = govtbond_trading_eodinfo(yldspdEOD,varargin)
if nargin > 2
    doPrint = varargin{1};
else
    doPrint = true;
end

%
lastbd = yldspdEOD.Data(end,1);
%
pxCloseYst5y = yldspdEOD.Data(end,2);
pxCloseChgYst5y = pxCloseYst5y-yldspdEOD.Data(end-1,2);
yldCloseYst5y = yldspdEOD.Data(end,4);
yldCloseChgYst5y = yldCloseYst5y-yldspdEOD.Data(end-1,4);
mdClose5y = yldspdEOD.Data(end,7);

if doPrint
    fprintf('\n');
    fprintf('CN govtbond %2dy futs-->>cob date:%s',5,datestr(lastbd));
    fprintf(';px:%4.3f',pxCloseYst5y);
    fprintf(';px chg:%4.3f',pxCloseChgYst5y);
    fprintf(';yld:%4.2f%%;yld chg(bp):%2.1f',...
    yldCloseYst5y*100,yldCloseChgYst5y*10000);
    fprintf(';dur:%4.2f\n',mdClose5y);
end
%
%
pxCloseYst10y = yldspdEOD.Data(end,3);
pxCloseChgYst10y = pxCloseYst10y-yldspdEOD.Data(end-1,3);
yldCloseYst10y = yldspdEOD.Data(end,5);
yldCloseChgYst10y = yldCloseYst10y-yldspdEOD.Data(end-1,5);
mdClose10y = yldspdEOD.Data(end,8);

lastSlope = yldspdEOD.Data(end,6);
lastSlopeChg = lastSlope - yldspdEOD.Data(end-1,6);

if doPrint
    fprintf('CN govtbond %2dy futs-->>cob date:%s',10,datestr(lastbd));
    fprintf(';px:%4.3f',pxCloseYst10y);
    fprintf(';px chg:%4.3f',pxCloseChgYst10y);
    fprintf(';yld:%4.2f%%;yld chg(bp):%2.1f',...
        yldCloseYst10y*100,yldCloseChgYst10y*10000);
    fprintf(';dur:%4.2f\n',mdClose10y);
    fprintf('yld curve slope(bp):%4.1f\n',lastSlope);
    fprintf('yld curve slope chg(bp):%4.2f\n',lastSlopeChg);
end
%
%
%construct output
output = struct('LastBusinessDate',lastbd,...
    'PxCloseYst',[pxCloseYst5y,pxCloseYst10y],...
    'PxCloseChgYst',[pxCloseChgYst5y,pxCloseChgYst10y],...
    'YldCloseYst',[yldCloseYst5y,yldCloseYst10y],...
    'YldCloseChgYst',[yldCloseChgYst5y*10000,yldCloseChgYst10y*10000],...
    'Duration',[mdClose5y,mdClose10y]);


end

