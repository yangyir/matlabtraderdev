function contracts = listcontracts_basemetal(assetName,varargin)
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('AssetName',@ischar);
p.addParameter('BloombergCode',{},...
       @(x) validateattributes(x,{'cell','char'},{},'','BloombergCode'));
p.addParameter('WindCode',{},...
       @(x) validateattributes(x,{'cell','char'},{},'','WindCode'));
p.addParameter('Exchange',{},...
       @(x) validateattributes(x,{'cell','char'},{},'','Exchange'));
p.parse(assetName,varargin{:});
assetName = p.Results.AssetName;
bcode = p.Results.BloombergCode;
wcode = p.Results.WindCode;
exchange = p.Results.Exchange;
if isempty(wcode)
    iswind = 0;
else
    iswind = 1;
end

%
%the history for copper and aluminum is much longer
%and we select Jan05 as our start date
if strcmpi(assetName,'copper') || strcmpi(assetName,'aluminum')
    init_mm = 1;
    init_yy = 2005;
elseif strcmpi(assetName,'zinc')
    init_mm = 7;
    init_yy = 2007;
elseif strcmpi(assetName,'lead')
    init_mm = 9;
    init_yy = 2011;
elseif strcmpi(assetName,'nickel')
    init_mm = 9;
    init_yy = 2015;
else
    error(['invalid base metal:',assetName]);
end
curr_dd = today;
curr_yy = year(curr_dd);
curr_mm = month(curr_dd);
yy_str = num2str(curr_yy);
%
%note that all based metals apart from nickel expired on the 15th
%(or the following business date in case it is a public holiday) 
%on the curent month. 
%the active month for nickel is jan,may and sep
if ((strcmpi(assetName,'nickel') && (curr_mm==1 || curr_mm==5 || curr_mm==9))...
        || ~strcmpi(assetName,'nickel'))
    if curr_mm<10
        mm_str = ['0',num2str(curr_mm)];
    else
        mm_str = num2str(curr_mm);
    end
    mid_month_date = datenum([yy_str,mm_str,'15'],'yyyymmdd');
    wkd = weekday(mid_month_date);
    if wkd==1
        mid_month_date = mid_month_date+1;
    elseif wkd==6
        mid_month_date = mid_month_date+2;
    end
    if curr_dd>mid_month_date
        curr_mm = curr_mm+6;
        if curr_mm>12
            curr_mm=curr_mm-12;
            curr_yy=curr_yy+1;
        end
    end      
end


if strcmpi(assetName,'nickel')
    if init_yy < curr_yy
        n = 1+...                       %contracts for the first year
            (curr_yy-1-init_yy)*3+...   %contracts between the 2nd and last year
            ceil(curr_mm/4)+...         %contracts (expired) for this year
            3;                          %now listed
    else
        n = ceil((curr_mm-init_mm+1)/4)+3;
    end
else
    if init_yy < curr_yy
        n = (12-init_mm+1)+...          %contracts for the first year
            (curr_yy-1-init_yy)*12+...  %contracts between the 2nd and last year
            curr_mm+...                 %contracts for this year
            3;                          %now listed and activly traded
    else
        n = (curr_mm-init_mm+1)+3;
    end
end
contracts = cell(n,1);
i=1;
while i<=n
    if strcmpi(assetName,'nickel')
        mm = (i-1)*4+init_mm;
    else
        mm = i+init_mm-1;
    end
    if mod(mm,12)==0
        yy = init_yy+mm/12-1;
    else
        yy = init_yy+floor(mm/12);
    end
    yy_str = num2str(yy);
    mm = mod(mm,12);
    if mm==0
        mm=12;
    end
    if mm<10
        mm_str = ['0',num2str(mm)];
    else
        mm_str = num2str(mm);
    end
    if iswind
        contracts{i,1} = [wcode,yy_str(end-1:end),mm_str,exchange];
    else
        futcode = getfutcode(str2double(mm_str));
        if str2double(yy_str) >= curr_yy
            contracts{i,1} = [bcode,futcode,yy_str(end),' Comdty'];
        else
            contracts{i,1} = [bcode,futcode,yy_str(end-1:end),' Comdty'];
        end
    end
    i=i+1;
end
    
end