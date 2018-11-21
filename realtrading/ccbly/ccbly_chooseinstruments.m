%%user inputs
%note: 
%assettypes data type is cell
%assetnames data type is cell
%conditiontype data type is char and must either be 'OR' or 'AND'
fprintf('running ccbly_chooseinstruments...\n');

ccblyfut_assettypes = {'basemetal';'preciousmetal';'govtbond';'eqindex'};
ccblyfut_assetnames = {'crude oil';'deformed bar';'iron ore'};
ccblyfut_conditiontype = 'or';

ccblyfut_futs2trade = getactivefuts('AssetTypes',ccblyfut_assettypes,...
    'AssetNames',ccblyfut_assetnames,...
    'ConditionType',ccblyfut_conditiontype);
if ~isempty(ccblyfut_futs2trade)
    fprintf('selected instruments:\n');
    for i = 1:size(ccblyfut_futs2trade,1),fprintf('\t%s\n',ccblyfut_futs2trade{i});end
end

