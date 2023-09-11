function bcode = ctp2bbg(codestr)
%function to transform the ctpcode, e.g. ni1801 to bbg code,
%e.g.XIIF8 Comdty
if ~ischar(codestr)
    error('ctp2bbg:char type of ctp code input expected')
end

for i = 1:length(codestr)
    if isnumchar(codestr(i))
        break
    end
end

idx = i-1;
if idx == 0
    error('ctp2bbg:invalid ctp code input')
end

assetshortcode = codestr(1:idx);
tenor = codestr(idx+1:end);
if length(tenor) > 4
    opt = true;
else
    opt = false;
end

if ~opt
    mmstr = tenor(end-1:end);
    yystr = tenor(1:length(tenor)-2);
    yynum = str2double(yystr);
else
    %for comdty options
    %it works for now but might be revised given shanghai cu option in the
    %list
    for i = 1:length(tenor)
        if ~isnumchar(tenor(i)), break; end
    end
    
    tenorstr = tenor(1:i-1);
    mmstr = tenorstr(end-1:end);
    yystr = tenorstr(1:length(tenorstr)-2);
    yynum = str2double(yystr);
    
    if ~(strcmpi(tenor(i),'C') || strcmpi(tenor(i),'P')), i = i + 1;end
    
    opt_type = upper(tenor(i));
    idx = i+1;
    for i = idx:length(tenor)
        if isnumchar(tenor(i)),break;end
    end
    opt_strike = tenor(i:end);
    
end
        
if length(yystr) == 1
    %Ö£ÉÌËù
    if year(today) < 2019
        if yynum < year(today)-2010
            byystr = ['1',yystr];
        else
            byystr = yystr(end);
        end
    else
        if yynum < year(today)-2020
            byystr = ['2',yystr];
        else
            byystr = yystr(end);
        end
    end
else
    if yynum < year(today)-2000
        byystr = yystr;
    else
        byystr = yystr(end);
    end
end
    

fcode = getfutcode(str2double(mmstr));

[~,~,codelist1,codelist2]=getassetmaptable;
bcode = '';

if strcmpi(assetshortcode,'IO')
    [~,~,~,~,opt_expiry] = isoptchar(codestr);
    bcode = ['SHSN300 ',datestr(opt_expiry,'mm/dd/yy'),' ',opt_type,opt_strike,' Index'];
else
    for i = 1:size(codelist1)
        if strcmpi(assetshortcode,codelist2{i}) || ...
            (strcmpi(assetshortcode,'ME') && strcmpi(codelist2{i},'MA')) || ...
                (strcmpi(assetshortcode,'TC') && strcmpi(codelist2{i},'ZC')) || ...
                (strcmpi(assetshortcode,'RO') && strcmpi(codelist2{i},'OI'))
            if ~opt
                if strcmpi(assetshortcode,'IF') || strcmpi(assetshortcode,'IC') || strcmpi(assetshortcode,'IH')
                    bcode = [codelist1{i},fcode,byystr,' Index'];
                else
                    bcode = [codelist1{i},fcode,byystr,' Comdty'];
                end
            else
                bcode = [codelist1{i},fcode,byystr,opt_type,' ',opt_strike,' Comdty'];
            end
            break
        end
    end
end


end