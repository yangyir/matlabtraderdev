function [ ] = printpnltbl( pnltbl )
if ~isa(pnltbl,'table')
    error('invalid table object input')
end

fprintf('\nPnL table.....\n');
rownames = pnltbl.Properties.RowNames;
fprintf('%11s','ticker');
fprintf('%13s','total');
fprintf('%10s','theta');
fprintf('%10s','delta');
fprintf('%11s','gamma');
fprintf('%11s','vega');
fprintf('%11s','other');
fprintf('%10s','volume');
fprintf('%11s','ivbase');
fprintf('%12s','ivcarry');
fprintf('\n');
for i = 1:size(rownames,1);
    fprintf('%12s',rownames{i});
    fprintf('%12.0f',pnltbl.total(i));
    fprintf('%10.0f',pnltbl.theta(i));
    fprintf('%10.0f',pnltbl.delta(i));
    fprintf('%10.0f',pnltbl.gamma(i));
    fprintf('%12.0f',pnltbl.vega(i));
    fprintf('%10.0f',pnltbl.unexplained(i));
    fprintf('%10.0f',pnltbl.volume(i));
    fprintf('%10.1f%%',pnltbl.ivbase(i)*100);
    fprintf('%10.1f%%',pnltbl.ivcarry(i)*100);
    fprintf('\n');
end



end

