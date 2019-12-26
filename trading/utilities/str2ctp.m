function ctpcode = str2ctp(codestr)
%��������Ӣ�Ĵ���Сд
%��������Ӣ�Ĵ���Сд
%֣������Ӣ�Ĵ����д
%�н�����Ӣ�Ĵ����д
%ע�ͣ�ת����������Ҫ�������ڻ��µ�

if ~ischar(codestr)
    error('str2ctp:char type of ctp code input expected')
end

for i = 1:length(codestr)
    if isnumchar(codestr(i))
        break
    end
end

idx = i-1;
if idx == 0
    error('str2ctp:invalid input')
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
        if isempty(idx)
            error('str2ctp:invalid input'); 
        end
    end
    tenor = [tenor(1:idx-1),upper(tenor(idx)),tenor(idx+1:end)];
    ctpcode = [upper(assetshortcode),tenor];
else
    [~,~,~,codelist,exlist]=getassetmaptable;
    for i = 1:size(codelist)
        if strcmpi(assetshortcode,codelist{i})
            if opt
                %we need to use the capital letter for 'C' and 'P'
                idx = strfind(upper(tenor),'C');
                if isempty(idx)
                    idx = strfind(upper(tenor),'P');
                    if isempty(idx)
                        error('str2ctp:invalid input'); 
                    end
                end
                tenor = [tenor(1:idx-1),upper(tenor(idx)),tenor(idx+1:end)];
            end
                
            if strcmpi(exlist{i},'.CFE') || strcmpi(exlist{i},'.CZC')
                ctpcode = [upper(assetshortcode),tenor];
            else
                ctpcode = [lower(assetshortcode),tenor];
            end
            break
        end
    end
end






end