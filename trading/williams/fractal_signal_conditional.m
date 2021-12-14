function [signal,op] = fractal_signal_conditional(extrainfo,ticksize,nfractal,varargin)
%return a signal in case there is neither valid breachup or valid breachdn
    signal = [];
    op = [];
    
    [validbreachhh,validbreachll] = fractal_validbreach(extrainfo,ticksize);
    if validbreachhh || validbreachll
        return
    end
    
    %long trend:
    %1a.1.there are 2*nfractal candles close above alligator's teeth
    %continuously with HH being above alligator's teeth;
    %1a.2:the lastest HH shall be above the previous HH, indicating an
    %upper trend;
    %1a.3:in case the lastest HH is below the previous HH,i.e.the previous
    %was formed given higher price volatility, we shall still regard the
    %up-trend as valid if and only if there are 2*nfracal candles close
    %above alligator's lips
    
    
    
    
    
    
    
end