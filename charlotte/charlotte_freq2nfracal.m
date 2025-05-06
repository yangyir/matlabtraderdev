function nfractal = charlotte_freq2nfractal(freq)
    if strcmpi(freq,'5m')
        nfractal = 6;
    elseif strcmpi(freq,'15m')
        nfractal = 4;
    elseif strcmpi(freq,'30m')
        nfractal = 4;
    elseif strcmpi(freq,'1h') || strcmpi(freq,'60m')
        nfractal = 4;
    elseif strcmpi(freq,'4h')
        nfractal = 2;
    elseif strcmpi(freq,'daily')
        nfractal = 2;
    else
        error('charlotte_freq2nfractal:invalid freq input')
    end
end