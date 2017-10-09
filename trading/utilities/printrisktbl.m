function [] = printrisktbl( risktbl )
if ~isa(risktbl,'table')
    error('invalid table object input')
end
fprintf('\nRisk table.....\n');
rownames = risktbl.Properties.RowNames;
fprintf('%11s','ticker');
fprintf('%13s','theta(r)');
fprintf('%12s','delta(r)');
fprintf('%12s','gamma(r)');
fprintf('%12s','vega(r)');
fprintf('%11s','volume');
fprintf('%11s','ivcarry');
fprintf('\n');
for i = 1:size(rownames,1);
    fprintf('%12s',rownames{i});
    fprintf('%11.0f',risktbl.thetacarry(i));
    fprintf('%12.0f',risktbl.deltacarry(i));
    fprintf('%12.0f',risktbl.gammacarry(i));
    fprintf('%12.0f',risktbl.vegacarry(i));
    fprintf('%10.0f',risktbl.volume(i));
    fprintf('%10.1f%%',risktbl.ivcarry(i)*100);
    fprintf('\n');
end

end

