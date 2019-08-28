clc;
errorfound = false;
for k = size(p,1)-1:-1:1
% for k = 1733
    bsin = bs(1:end-k+1);
    ssin = ss(1:end-k+1);
    lvlupin = lvlup(1:end-k+1);
    lvldnin = lvldn(1:end-k+1);
    bcin = bc(1:end-k);
    scin = sc(1:end-k);
    data = p(1:end-k+1,:);
    try
        [bcout,scout] = tdsq_piecewise_countdown(data,bsin,ssin,lvlupin,lvldnin,bcin,scin);
    catch
        errorfound = true;
        fprintf('error in %d\n',k);
        break
    end

    if isnan(bc(end-k+1)) && ~isnan(bcout(end))
        errorfound = true;
        fprintf('%3d:bc inconsistent\n',k);
        continue
    end
    if ~isnan(bc(end-k+1)) && (bc(end-k+1) ~= bcout(end))
        errorfound = true;
        fprintf('%3d:bc inconsistent\n',k);
        continue
    end
    
    
    if isnan(sc(end-k+1)) && ~isnan(scout(end))
        errorfound = true;
        fprintf('%3d:sc inconsistent\n',k);
        continue
    end
    if ~isnan(sc(end-k+1)) && (sc(end-k+1) ~= scout(end))
        errorfound = true;
        fprintf('%3d:sc inconsistent\n',k);
        continue
    end
end

if ~errorfound
    fprintf('regressiontest_tdsqpiecewisecountdownfunc:all clear!!\n')
end

