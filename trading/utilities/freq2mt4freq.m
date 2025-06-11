function freqOut = freq2mt4freq(freq)
    if strcmpi(freq,'5m')
        freqOut = 'M5';
    elseif strcmpi(freq,'15m')
        freqOut = 'M15';
    elseif strcmpi(freq,'30m')
        freqOut = 'M30';
    elseif strcmpi(freq,'60m')  || strcmpi(freq,'1h')
        freqOut = 'H1';
    elseif strcmpi(freq,'4h')
        freqOut = 'H4';
    else
        freqOut = 'D1';
    end
end