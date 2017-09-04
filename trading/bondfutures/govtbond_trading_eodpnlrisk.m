function govtbond_trading_eodpnlrisk(rollinfo5y,rollinfo10y,varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('Info5y',@isstruct);
p.addRequired('Info10y',@isstruct);
p.addParameter('CarryPositions',[],...
    @(x)validateattributes(x,{'struct'},{},'','CarryPositions'));
p.addParameter('TransactionRecords',[],...
    @(x)validateattributes(x,{'struct'},{},'','TransactionRecords'));
p.parse(rollinfo5y,rollinfo10y,varargin{:});
info5y = p.Results.Info5y;
info10y = p.Results.Info10y;
cob = info5y.ContinousFutures(end,1);
carryPos = p.Results.CarryPositions;
transactionRecords = p.Results.TransactionRecords;
if isempty(transactionRecords)
    hasIntradayTrades = false;
else
    hasIntradayTrades = true;
end

if isempty(carryPos) && ~hasIntradayTrades
    fprintf('cob date:%s\n\tempty bond futures positions!\n',datestr(cob));
    return
end


if ~hasIntradayTrades
    %first to print out pnl
    pos5y = carryPos.Position5y;
    pos10y = carryPos.Position10y;
    pxClose5y = info5y.ContinousFutures(end,2);
    pxClose10y = info10y.ContinousFutures(end,2);
    pxCloseYst5y = info5y.ContinousFutures(end-1,2);
    pxCloseYst10y = info10y.ContinousFutures(end-1,2);
    pnl5y = pos5y*(pxClose5y-pxCloseYst5y)*1e4;
    pnl10y = pos10y*(pxClose10y-pxCloseYst10y)*1e4;
    %
    fprintf('cob date:%s\n\t5y pnl:%+4.0f; 10y pnl:%+4.0f; total pnl:%+4.0f\n',...
        datestr(cob),pnl5y,pnl10y,pnl5y+pnl10y);
    %
    %second to print out risk
    mdur5y = bnddurp(pxClose5y,0.03,cob,dateadd(cob,'5y'));
    mdur10y = bnddurp(pxClose10y,0.03,cob,dateadd(cob,'10y'));
    bumpUp = 0.0001;
    bumpDn = -0.0001;
    pxBumpUp5y = pxClose5y-mdur5y*bumpUp*100;
    pxBumpDn5y = pxClose5y-mdur5y*bumpDn*100;
    pxBumpUp10y = pxClose10y-mdur10y*bumpUp*100;
    pxBumpDn10y = pxClose10y-mdur10y*bumpDn*100;
    %
    %parallel risk
    riskUp = (pxBumpUp5y-pxClose5y)*pos5y*1e4+...
        (pxBumpUp10y-pxClose10y)*pos10y*1e4;
    riskDn = (pxBumpDn5y-pxClose5y)*pos5y*1e4+...
        (pxBumpDn10y-pxClose10y)*pos10y*1e4;
    fprintf('\tparallel carry risk 1bp up:%+4.0f; 1bp dn:%+4.0f\n',riskUp,riskDn);
    %slope risk
    %1.slope move up 1bp, e.g the 5y doesn't move but the 10y move up by
    %1bp
    slopeRiskUp = (pxBumpUp10y-pxClose10y)*pos10y*1e4;
    %2.slope move dn 1bp, e.g. the 5y doesn't move but the 10y move dn by
    %1bp
    slopeRiskDn = (pxBumpDn10y-pxClose10y)*pos10y*1e4;
    fprintf('\tslope carry risk 1bp up:%+4.0f; 1bp dn:%+4.0f\n',slopeRiskUp,slopeRiskDn);
    
    
    
    

    
end


end