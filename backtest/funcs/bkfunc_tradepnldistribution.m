function [pnls,pnlBest,pnlWorst] = bkfunc_tradepnldistribution(tradeOpen,candles,varargin)
%
if ~isa(tradeOpen,'cTradeOpen')
    error('bkfunc_tradepnldistribution:invalid trade input!')
end

[nobs,ncols] = size(candles);
if ncols < 5
    error('bkfunc_tradepnldistribution:invalid candle input!')
end

idxOpen = find(tradeOpen.opendatetime1_ > candles(1:end-1,1) & tradeOpen.opendatetime1_ < candles(2:end,1), 1);
if isempty(idxOpen)
    if tradeOpen.opendatetime1_ - candles(end,1) < candles(end,1)-candles(end-1,1)
        idxOpen = nobs;
    else
        error('bkfunc_tradepnldistribution:trade open time cannot be found in candles!')
    end
end

p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('CarryPeriod',[],@isnumeric);
p.parse(varargin{:});
nCarryPeriod = p.Results.CarryPeriod;

if isempty(nCarryPeriod)
    idxStop = nobs;
else
    idxStop = idxOpen + nCarryPeriod;
    idxStop = min(idxStop,nobs);
end

openDirection = tradeOpen.opendirection_;
openPrice = tradeOpen.openprice_;
openVolume = tradeOpen.openvolume_;
instrument = tradeOpen.instrument_;


pnls = openDirection*(candles(idxOpen+1:idxStop,5) - openPrice)/instrument.tick_size*instrument.tick_value*openVolume;
if openDirection == 1
    pnlBest = openDirection*(max(candles(idxOpen:idxStop,3)) - openPrice)/instrument.tick_size*instrument.tick_value*openVolume;
    pnlWorst = openDirection*(min(candles(idxOpen:idxStop,4)) - openPrice)/instrument.tick_size*instrument.tick_value*openVolume;
else
    pnlBest = openDirection*(min(candles(idxOpen:idxStop,4)) - openPrice)/instrument.tick_size*instrument.tick_value*openVolume;
    pnlWorst = openDirection*(max(candles(idxOpen:idxStop,3)) - openPrice)/instrument.tick_size*instrument.tick_value*openVolume;
end


end

