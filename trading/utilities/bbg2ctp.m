function ctpcode = bbg2ctp(codestr)
%function to transform the bbgcode, e.g. XIIF8 Comdty to ctp code,
%e.g.ni1801
if ~ischar(codestr)
    error('bbg2ctp:char type of ctp code input expected')
end

idx_numchar = 0;
for i = 1:length(codestr)
    if isnumchar(codestr(i))
        idx_numchar = i;
        break
    end
end

if idx_numchar == 0
    error('bbg2ctp:invalid ctp code input')
end

%double check whether idx_numchar+1 is a numchar or not as for some bbgcode
%it uses XIIF07 for the contracts listed in the current year before
try
    flag = isnumchar(codestr(idx_numchar+1));
catch
    flag = false;
end

if flag
    yearstr = codestr(idx_numchar:idx_numchar+1);
else
    yearstr = codestr(idx_numchar);
end

if flag
    optstr = codestr(idx_numchar+2);
else
    optstr = codestr(idx_numchar+1);
end
if strcmpi(optstr,'C') || strcmpi(optstr,'P')
    isopt = true;
    if flag
        idx_opt = idx_numchar+2;
    else
        idx_opt = idx_numchar+1;
    end
else
    isopt = false;
end

bbgshortcode = codestr(1:idx_numchar-2);

monthcode = codestr(idx_numchar-1);
futcodelist = 'FGHJKMNQUVXZ';
mm = strfind(futcodelist,monthcode);

if mm < 10
    mmstr = ['0',num2str(mm)];
else
    mmstr = num2str(mm);
end

ctpshortcode = '';
[~,~,bbgcodelist,ctpcodelist,exlist]=getassetmaptable;
for i = 1:size(bbgcodelist,1)
    if strcmpi(bbgshortcode,bbgcodelist{i})
        ctpshortcode = ctpcodelist{i};
        excode = exlist{i};
        break
    end
end

if strcmpi(excode, '.CZC')
    ctpcode =[upper(ctpshortcode),yearstr,mmstr];
else
    currentyear = num2str(year(today));
    if length(yearstr) < 2
        yearstr = [currentyear(3),yearstr];
    end
    if strcmpi(excode,'.CFE')
        ctpcode =[upper(ctpshortcode),yearstr,mmstr];
    else
        ctpcode =[lower(ctpshortcode),yearstr,mmstr];
    end
end

if isopt
    idx_comdty = strfind(lower(codestr),'comdty');
    strikestr = codestr(idx_opt+1:idx_comdty-1);
    strike = str2double(strikestr);
    
    if strcmpi(ctpshortcode,'SR')
        ctpcode = [ctpcode,upper(codestr(idx_opt)),num2str(strike)];
    elseif strcmpi(ctpshortcode,'m')
        ctpcode = [ctpcode,'-',upper(codestr(idx_opt)),'-',num2str(strike)];
    elseif strcmpi(ctpshortcode,'cu')
        ctpcode = [ctpcode,upper(codestr(idx_opt)),num2str(strike)];
    else
        error('bbg2ctp:invalid codestr for listed option')
    end
end


end