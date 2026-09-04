function freqOut = freq2mt4freq(freq)
    if strcmpi(freq,'5m') || strcmpi(freq,'m5')
        freqOut = 'M5';
    elseif strcmpi(freq,'15m') || strcmpi(freq,'m15')
        freqOut = 'M15';
    elseif strcmpi(freq,'30m') || strcmpi(freq,'m30')
        freqOut = 'M30';
    elseif strcmpi(freq,'60m')  || strcmpi(freq,'1h') || strcmpi(freq,'h1')
        freqOut = 'H1';
    elseif strcmpi(freq,'4h') || strcmpi(freq,'h4')
        freqOut = 'H4';
    else
        freqOut = 'D1';
    end
end