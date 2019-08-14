function [indicators,wrseries,maxcandle,mincandle] = calc_wr_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('NumOfPeriods',144,...
        @(x) validateattributes(x,{'numeric'},{},'','NumOfPeriods'));
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.addParameter('RemoveLimitPrice',0,@isnumeric);
    p.parse(instrument,varargin{:});
    instrument = p.Results.Instrument;
    includeLastCandle = p.Results.IncludeLastCandle;
    removeLimitPrice = p.Results.RemoveLimitPrice;
    
    candlesticks = mdefut.getallcandles(instrument);
    candlesall = candlesticks{1};
    if ~includeLastCandle && ~isempty(candlesall)
        candlesall = candlesall(1:end-1,:);
    end
    
    if removeLimitPrice
        idxremove = candlesall(:,2)==candlesall(:,3)&candlesall(:,2)==candlesall(:,4)&candlesall(:,2)==candlesall(:,5);
        idxkeep = ~idxremove;
        candlesall = candlesall(idxkeep,:);
    end
    
    timevec = candlesall(:,1);
    highp = candlesall(:,3);
    lowp = candlesall(:,4);
    closep = candlesall(:,5);
    
    [~,idx] = mdefut.qms_.instruments_.hasinstrument(instrument);
    try
        nperiods = mdefut.wrnperiod_(idx);
    catch
        nperiods = p.Results.NumOfPeriods;
    end

    if size(closep,1) >= nperiods
        wrs = willpctr(highp,lowp,closep,nperiods);
        maxp = max(highp(end-nperiods+1:end));
        minp = min(lowp(end-nperiods+1:end));
        lastclose = closep(end);
        %
        %additional info
        maxp_before = max(highp(end-nperiods:end-1));
        minp_before = min(lowp(end-nperiods:end-1));
        idxmaxp = highp == maxp;
        maxt = timevec(idxmaxp);
        maxcandle = candlesall(idxmaxp,:);
        if size(maxt,1) > 1
            maxt = maxt(end);
            maxcandle = maxcandle(end,:);
        end
        
        idxminp = lowp == minp;
        mint = timevec(idxminp);
        mincandle = candlesall(idxminp,:);
        if size(mint,1) > 1
            mint = mint(end);
            mincandle = mincandle(end,:);
        end
        %
        indicators = [wrs(end),maxp,minp,lastclose,maxt,mint,maxp_before,minp_before];
        wrseries = wrs;
    else
        indicators = [];
        wrseries = [];
    end

end
%end of calc_wr_