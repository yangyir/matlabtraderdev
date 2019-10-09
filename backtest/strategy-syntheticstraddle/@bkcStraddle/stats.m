function outputs = stats(obj)
%bkcStraddle
    outputs = [];
    if isempty(obj.pvs_),return;end
    rets = obj.pvs_(2:end)./obj.pvs_(1)-1;
    maxret = max(rets);
    maxretidx = find(rets == maxret,1,'first');
    if ~isempty(maxretidx)
        minretb4max = min(rets(1:maxretidx));
    else
        minretb4max = NaN;
        maxretidx = -1;
    end
    outputs = struct('maxret',maxret,'maxretidx',maxretidx+1,...
        'minretbeforemax',minretb4max);
end