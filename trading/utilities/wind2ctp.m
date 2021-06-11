function ctpcode = wind2ctp(codestr)
%function to transform the windcode, e.g. NI1801.SHF to ctp code
%all wind codes are in capital letters
if ~ischar(codestr)
    error('wind2ctp:char type of wind code input expected')
end

for i = 1:length(codestr)
    if isnumchar(codestr(i))
        break
    end
end

idx = i-1;
if idx == 0
    error('wind2ctp:invalid wind code input')
end

assetshortcode = codestr(1:idx);

idxdot = strfind(codestr,'.');
if isempty(idxdot)
    error('wind2ctp:invalid wind code input:missing exchange info')
end

exchangecode = codestr(idxdot:end);

if strcmpi(exchangecode,'.CFE')
    %upper case
    ctpcode = codestr(1:idxdot-1);
elseif strcmpi(exchangecode,'.SHF')
    %lower case
    ctpcode = lower(codestr(1:idxdot-1));
elseif strcmpi(exchangecode,'.DCE')
    %lower case
    ctpcode = lower(codestr(1:idxdot-1));
elseif strcmpi(exchangecode,'.CZC')
    %upper case
    ctpcode = codestr(1:idxdot-1);
end




end