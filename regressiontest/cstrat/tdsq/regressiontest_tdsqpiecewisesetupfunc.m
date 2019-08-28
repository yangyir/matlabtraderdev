clc;
errorfound = false;
for k = size(p,1)-1:-1:1
    bsin = bs(1:end-k);
    ssin = ss(1:end-k);
    lvlupin = lvlup(1:end-k);
    lvldnin = lvldn(1:end-k);
    bcin = bc(1:end-k);
    scin = sc(1:end-k);
    data = p(1:end-k+1,:);

    [bsout,ssout,lvlupout,lvldnout] = tdsq_piecewise_setup(data,bsin,ssin,lvlupin,lvldnin);

    if bsout(end) ~= bs(end-k+1)
        fprintf('%3d:bs inconsistent\n',k);
        errorfound = true;
    end
    
    if ssout(end) ~= ss(end-k+1)
        fprintf('%3d:ss inconsistent\n',k);
        errorfound = true;
    end
    
    if isnan(lvlup(end-k+1)) && ~isnan(lvlupout(end))
        fprintf('%3d:lvlup inconsistent\n',k);
        errorfound = true;
    end
    if ~isnan(lvlup(end-k+1)) && (lvlup(end-k+1) ~= lvlupout(end))
        fprintf('%3d:lvlup inconsistent\n',k);
        errorfound = true;
    end
    
    if isnan(lvldn(end-k+1)) && ~isnan(lvldnout(end))
        fprintf('%3d:lvldn inconsistent\n',k);
        errorfound = true;
    end
    if ~isnan(lvldn(end-k+1)) && (lvldn(end-k+1) ~= lvldnout(end))
        fprintf('%3d:lvldn inconsistent\n',k);
        errorfound = true;
    end
    
end

if ~errorfound
    fprintf('regressiontest_tdsqpiecewisesetupfunc:all clear!!\n')
end

