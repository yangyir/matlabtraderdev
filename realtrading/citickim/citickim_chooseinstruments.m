%%user inputs
%note: 
%assettypes data type is cell
%assetnames data type is cell
%conditiontype data type is char and must either be 'OR' or 'AND'
fprintf('running ''citickim_chooseinstruments''...\n');

if exist('ui_assettypes','var')
    citickim_assettypes = ui_assettypes;
else
    citickim_assettypes = {'basemetal';'preciousmetal';'govtbond';'energy'};
end
%
if exist('ui_assetnames','var')
    citickim_assetnames = ui_assetnames;
else
    citickim_assetnames = {'deformed bar';'iron ore';...
        'sugar';'soymeal';'palm oil';'corn';'rapeseed meal';'apple'};
end
citickim_conditiontype = 'or';

citickim_futs2trade = getactivefuts('AssetTypes',citickim_assettypes,...
    'AssetNames',citickim_assetnames,...
    'ConditionType',citickim_conditiontype);
if ~isempty(citickim_futs2trade)
    fprintf('selected instruments:\n');
    for i = 1:size(citickim_futs2trade,1),fprintf('\t%s\n',citickim_futs2trade{i});end
end

clear i
