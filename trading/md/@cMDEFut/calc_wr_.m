function indicators = calc_wr_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('NumOfPeriods',144,...
        @(x) validateattributes(x,{'numeric'},{},'','NumOfPeriods'));
    p.parse(instrument,varargin{:});
    instrument = p.Results.Instrument;
    nperiods = p.Results.NumOfPeriods;

    histcandles = mdefut.gethistcandles(instrument);
    candlesticks = mdefut.getcandles(instrument);

    highp = [histcandles(:,3);candlesticks(:,3)];
    lowp = [histcandles(:,4);candlesticks(:,4)];
    closep = [histcandles(:,5);candlesticks(:,5)];

    indicators = willpctr(highp,lowp,closep,nperiods);

end
%end of calc_wr_