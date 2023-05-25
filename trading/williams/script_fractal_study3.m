%% all long with strong breach and it is trending
n = size(tblb_data_combo,1);
idx = zeros(n,1);
assetname = cell(n,1);
pnlrel = zeros(n,1);
notional = zeros(n,1);
for i = 1:n
    if isempty(tblb_data_combo{i,14}),continue;end
    if isempty(tblb_data_combo{i,20}),continue;end
    if tblb_data_combo{i,2} == 3 && tblb_data_combo{i,37} == 1
        idx(i) = 1;
        fut = code2instrument(tblb_data_combo{i,14});
        assetname{i} = fut.assetname;
        pnlrel(i) = tblb_data_combo{i,18}/tblb_data_combo{i,17}/fut.contract_size;
        notional(i) = 
    end
end

