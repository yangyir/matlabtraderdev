function wcode = ctp2wind(codestr)
%function to transform the ctpcode, e.g. ni1801 to wind code,
%e.g.NI1801.SHF
if ~ischar(codestr)
    error('ctp2wind:char type of ctp code input expected')
end

for i = 1:length(codestr)
    if isnumchar(codestr(i))
        break
    end
end

idx = i-1;
if idx == 0
    error('ctp2wind:invalid ctp code input')
end

assetshortcode = codestr(1:idx);
tenor = codestr(idx+1:end);
if length(tenor) > 4
    opt = true;
else
    opt = false;
end

if strcmpi(assetshortcode,'IO')
    idx = strfind(upper(tenor),'C');
    if isempty(idx)
        idx = strfind(upper(tenor),'P');
        if isempty(idx), error('str2ctp:invalid input'); end
    end
    tenor = [tenor(1:idx-1),upper(tenor(idx)),tenor(idx+1:end)];
    wcode = [assetshortcode,tenor,'.CFE'];
else
    [~,~,~,codelist,exlist]=getassetmaptable;
    wcode = '';
    for i = 1:size(codelist)
        if strcmpi(assetshortcode,codelist{i}) || ...
                (strcmpi(assetshortcode,'ME') && strcmpi(codelist{i},'MA')) || ...
                (strcmpi(assetshortcode,'TC') && strcmpi(codelist{i},'ZC')) || ...
                (strcmpi(assetshortcode,'RO') && strcmpi(codelist{i},'OI'))
            if opt
                %we need to use the capital letter for 'C' and 'P'
                idx = strfind(upper(tenor),'C');
                if isempty(idx)
                    idx = strfind(upper(tenor),'P');
                    if isempty(idx), error('str2ctp:invalid input'); end
                end
                tenor = [tenor(1:idx-1),upper(tenor(idx)),tenor(idx+1:end)];
            end
            wcode = [codelist{i},tenor,exlist{i}];
            break
        end
    end
end


end