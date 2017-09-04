function contract = windcode2contract(windcode)
if ~ischar(windcode)
    error('windcode2contract:invalid input data type of wincode')
end

for i = 1:length(windcode)
    check = str2double(windcode(i));
    if ~isnan(check)
        break
    end
end

idx = i-1;
if idx == 0
    error('windcode2contract:invalid windcode input')
end

windCodeStr = windcode(1:idx);
tenor = windcode(idx+1:end);

[assetList,~,~,windCodeList]=getassetmaptable;
assetName ={};
for i = 1:size(windCodeList,1)
    if strcmpi(windCodeStr,windCodeList{i})
        assetName = assetList{i};
        break
    end
end

if ~isempty(assetName)
    contract = cContract('assetname',assetName,'tenor',tenor);
else
    error('windcode2contract:invalid windcode input')
end

end