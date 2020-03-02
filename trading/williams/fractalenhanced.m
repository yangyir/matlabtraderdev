function [ idx,HH,LL,upperchannel,lowerchannel,volsmooth] = fractalenhanced( p,nperiod,varargin )
%FRACTALENHANCED Summary of this function goes here
% the fractal enhanced indicator draws range boxes overlaid on the
% price chart. the upper and lower side of the boxes are made from recent
% fractals. new boxes will be drawn only if the volatility is weak and it
% the new fractals discovered are far enough from the current upper and
% lower ones.
    ip = inputParser;
    ip.CaseSensitive = false;ip.KeepUnmatched = true;
    ip.addParameter('volatilityperiod',13,@isnumeric);
    ip.addParameter('tolerance',0.003,@isnumeric);
    ip.parse(varargin{:});
    inpbandsperiod = ip.Results.volatilityperiod;
    change = ip.Results.tolerance;
    
    if inpbandsperiod < 0
        error('fractalenhanced:volatilityperiod shall be non-negative')
    end
    
    if change < 0
        error('fractalenhanced:tolerance input shall be non-negative')
    end
    
    [idx,HH,LL] = fractal(p,nperiod);
    
    if inpbandsperiod == 0 && change == 0
        upperchannel = HH;
        lowerchannel = LL;
        return;
    end
    
    np = size(p,1);
    if inpbandsperiod == 0 && change > 0
        upperchannel = HH;
        lowerchannel = LL;
        for i = 2:np
            if abs((HH(i)-upperchannel(i-1))/p(i,5))>change
                upperchannel(i) = HH(i);
            else
                if ~isnan(upperchannel(i-1))
                    upperchannel(i) = upperchannel(i-1);
                end
            end
            %
            if abs((LL(i)-lowerchannel(i-1))/p(i,5))>change
                lowerchannel(i) = LL(i);
            else
                if ~isnan(lowerchannel(i-1))
                    lowerchannel(i) = lowerchannel(i-1);
                end
            end
        end
        return
    end
    
    sigma = nan(np,1);
    for i = 1:np
        if i < inpbandsperiod, continue;end
        sigma(i) = std(p(i-inpbandsperiod+1:i,5));
    end
    highindex = nan(np,1);
    lowindex = nan(np,1);
    volder = nan(np,1);
    for i = 1:np
        if i < 2*inpbandsperiod, continue;end
        highindex(i) = max(sigma(i-inpbandsperiod:i-1));
        lowindex(i) = min(sigma(i-inpbandsperiod:i-1));
        volder(i) = (sigma(i)-highindex(i))/(highindex(i)-lowindex(i));
    end
    %
    smooth = 2; % smoothness
    [~,volsmooth] = movavg(volder,1,smooth);
    volsmooth = min(max(volsmooth,-1),0);

    
        
    upperchannel = HH;
    lowerchannel = LL;
    
    for i = 2:np
        if volsmooth(i) == -1
            if abs(HH(i)-upperchannel(i-1))/abs(p(i,5))>change
                upperchannel(i) = HH(i);
            else
                if ~isnan(upperchannel(i-1))
                    upperchannel(i) = upperchannel(i-1);
                end
            end
            %
            if abs(LL(i)-lowerchannel(i-1))/abs(p(i,5))>change
                lowerchannel(i) = LL(i);
            else
                if ~isnan(lowerchannel(i-1))
                    lowerchannel(i) = lowerchannel(i-1);
                end
            end
        else
            if ~isnan(upperchannel(i-1))
                upperchannel(i) = upperchannel(i-1);
            end
            if ~isnan(lowerchannel(i-1))
                lowerchannel(i) = lowerchannel(i-1);
            end
        end
    end
    
    
end

