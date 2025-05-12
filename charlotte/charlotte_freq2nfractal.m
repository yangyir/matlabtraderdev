function nfractal = charlotte_freq2nfractal(freq)
    if strcmpi(freq,'5m') || strcmpi(freq,'m5')
        nfractal = 6;
    elseif strcmpi(freq,'15m') || strcmpi(freq,'m15') 
        nfractal = 4;
    elseif strcmpi(freq,'30m') || strcmpi(freq,'m30')
        nfractal = 4;
    elseif strcmpi(freq,'1h') || strcmpi(freq,'60m') || strcmpi(freq,'h1')
        nfractal = 4;
    elseif strcmpi(freq,'4h') || strcmpi(freq,'h4')
        nfractal = 2;
    elseif strcmpi(freq,'daily') || strcmpi(freq,'d1')
        nfractal = 2;
    else
        error('charlotte_freq2nfractal:invalid freq input')
    end
end