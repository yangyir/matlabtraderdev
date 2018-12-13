%%user inputs
%note: 
%assettypes data type is cell
%assetnames data type is cell
%conditiontype data type is char and must either be 'OR' or 'AND'
fprintf('running ''ccbly_chooseinstruments''...\n');

if exist('ui_assettypes','var')
    ccbly_assettypes = ui_assettypes;
else
    ccbly_assettypes = {'basemetal';'preciousmetal';'govtbond';'energy'};
end
%
if exist('ui_assetnames','var')
    ccbly_assetnames = ui_assetnames;
else
    ccbly_assetnames = {'deformed bar';'iron ore';...
        'sugar';'soymeal';'palm oil';'corn';'rapeseed meal';'apple'};
end
ccbly_conditiontype = 'or';

ccbly_futs2trade = getactivefuts('AssetTypes',ccbly_assettypes,...
    'AssetNames',ccbly_assetnames,...
    'ConditionType',ccbly_conditiontype);
if ~isempty(ccbly_futs2trade)
    fprintf('selected instruments:\n');
    for i = 1:size(ccbly_futs2trade,1),fprintf('\t%s\n',ccbly_futs2trade{i});end
end

clear i
