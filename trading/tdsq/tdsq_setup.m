function [ bs,ss ] = tdsq_setup( data,varargin )
%TDSQ_SETUP Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Lag',4,@isnumeric);
    p.addParameter('Consecutive',9,@isnumeric);
    p.parse(varargin{:});
    nLag = p.Results.Lag;
        
    n = size(data,1);
    bearishMACDFlip = zeros(n,1);
    bullishMACDFlip = zeros(n,1);
    bs = zeros(n,1);
    ss = zeros(n,1);
    
    i = nLag + 2;
    while i <= n
        if data(i-1,end) >= data(i-1-nLag,end) && data(i,end) < data(i-nLag,end)
            bearishMACDFlip(i,1) = 1;
        end
        if bearishMACDFlip(i,1) == 1
            bs(i,1) = 1;
            for j = i+1:n
                if data(j,end) < data(j-nLag,end)
                    bs(j,1) = bs(j-1,1)+1;
                else
                    break
                end
            end
            i = j;
        else
            i = i + 1;
        end
    end
    %
    i = nLag + 2;
    while i <= n
        if data(i-1,end) <= data(i-1-nLag,end) && data(i,end) > data(i-nLag,end)
            bullishMACDFlip(i,1) = 1;
        end
        if bullishMACDFlip(i,1) == 1
            ss(i,1) = 1;
            for j = i+1:n
                if data(j,end) > data(j-nLag,end)
                    ss(j,1) = ss(j-1,1)+1;
                else
                    break
                end
            end
            i = j;
        else
            i = i + 1;
        end
    end

end

