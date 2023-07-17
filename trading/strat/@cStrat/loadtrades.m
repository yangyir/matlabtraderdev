function [] = loadtrades(strategy,varargin)
%cStrat doesn't load trades
%function shall be called between 1) %08:50am and 09:00am or 
%2)between 20:50pm and 21:00pm;
%3we tried to reset signal calc bucket before market open for daily trade

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.Time;
    hh = hour(t);
      
    n = strategy.count;
    instruments = strategy.getinstruments;
    for i = 1:n
        freq = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
        if ~strcmpi(freq,'1440m'),continue;end
        category = getfutcategory(instruments{i});
        if category == 1 || category == 2 || category == 3
            if hh < 9
                strategy.calsignal_bucket_(i) = 0;
            end
        elseif category == 4 || 5
            if hh > 15 && hh < 21
%                 strategy.calsignal_bucket_(i) = 0;
            end
        end
            
        
    end
end