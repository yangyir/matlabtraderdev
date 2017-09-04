function contracts = listcontracts_preciousmetal(assetName,varargin)
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
%first gold contract expired in Jun09
if strcmpi(assetName,'gold')  
    init_mm = 6;
    init_yy = 2009;
%first silver contract expired in Dec12
elseif strcmpi(assetName,'silver')                    
    init_mm = 12;
    init_yy = 2012;
end

curr_dd = today;
curr_yy = year(curr_dd);
curr_mm = month(curr_dd);
yy_str = num2str(curr_yy);
%
%note that the gold/silver expired on the 15th(or the following business date
%in case it is a public holiday) on the expiry month, i.e. jun and dec
if mod(curr_mm,6) == 0
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

%number of contracts traded in total
n = ceil((12-init_mm+1)/6)+...  %contracts for the 1st year
    (curr_yy-1-init_yy)*2+...   %contracts between next year and last year
    floor(curr_mm/6)+...        %contracts before this month in this year
    2;                          %listed contract from this month
if mod(curr_mm,6)==0
    n=n-1;
end

%
contracts = cell(n,1);
i=1;
while i<=n
    mm = (i-1)*6+init_mm;
    if mod(mm,12)==0
        yy = init_yy+mm/12-1;
    else
        yy = init_yy+floor(mm/12);
    end
    yy_str = num2str(yy);
    mm = mod(mm,12);
    if mm==0
        mm = 12;
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
    i = i+1;
end

end