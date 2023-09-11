function [assetname,exch] = getexchangestr(obj)
    ctpstr = obj.code_ctp;
    if isempty(ctpstr)
        assetname = '';
        exch = '';
        return
    end

    for i = 1:length(ctpstr)
        if isnumchar(ctpstr(i)), break; end
    end
    idx = i-1;
    assetshortcode = ctpstr(1:idx);
    [assetlist,~,~,codelist,exlist]=getassetmaptable;
    for i = 1:size(codelist)
        if strcmpi(assetshortcode,codelist{i}) || ...
                (strcmpi(assetshortcode,'ME') && strcmpi(codelist{i},'MA')) || ...
                (strcmpi(assetshortcode,'TC') && strcmpi(codelist{i},'ZC')) || ...
                (strcmpi(assetshortcode,'RO') && strcmpi(codelist{i},'OI'))
            assetname = assetlist{i};
            exch = exlist{i};
            return
        end
    end
    exch = 'unknown';
end
%end of getexchangestr
