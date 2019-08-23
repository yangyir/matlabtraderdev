clc;
% for k = 300:-1:1
for k = 300
    bsin = bs(1:end-k);
    ssin = ss(1:end-k);
    lvlupin = lvlup(1:end-k);
    lvldnin = lvldn(1:end-k);
    bcin = bc(1:end-k);
    scin = sc(1:end-k);
    data = p(1:end-k+1,:);

    [bsout,ssout,lvlupout,lvldnout,bcout,scout] = tdsq_piecewise(data,bsin,ssin,lvlupin,lvldnin,bcin,scin);

    if bsout(end) ~= bs(end-k+1)
        fprintf('%3d:bs inconsistent\n',k);
    end
    
    if ssout(end) ~= ss(end-k+1)
        fprintf('%3d:ss inconsistent\n',k);
    end
    
    if lvlupout(end) ~= lvlup(end-k+1)
        fprintf('%3d:lvlup inconsistent\n',k);
    end
    
    if lvldnout(end) ~= lvldn(end-k+1)
        fprintf('%3d:lvldn inconsistent\n',k);
    end
    
    if isnan(bc(end-k+1)) && ~isnan(bcout(end))
        fprintf('%3d:bc inconsistent\n',k);
    end
    if ~isnan(bc(end-k+1)) && (bc(end-k+1) ~= bcout(end))
        fprintf('%3d:bc inconsistent\n',k);
    end
    
    if isnan(sc(end-k+1)) && ~isnan(scout(end))
        fprintf('%3d:sc inconsistent\n',k);
    end
    if ~isnan(sc(end-k+1)) && (sc(end-k+1) ~= scout(end))
        fprintf('%3d:sc inconsistent\n',k);
    end
end

% fprintf('all clear\n')

