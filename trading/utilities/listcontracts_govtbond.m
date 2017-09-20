function contracts = listcontracts_govtbond(assetName,varargin)
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
%first 5y govtbond futures contract expired in Dec13
if strcmpi(assetName,'govtbond_5y')
    init_mm = 12;
    init_yy = 2013;
%first 10y govtbond futures contract expired in Sep15
elseif strcmpi(assetName,'govtbond_10y')
    init_mm = 9;
    init_yy = 2015;
end

curr_dd = today;
curr_yy = year(curr_dd);
curr_mm = month(curr_dd);
yy_str = num2str(curr_yy);
%
%note that the govtbond futures expired on the 2nd friday of the month
%once the 1st futures contract expired, it rolled to the next one
%e.g.the first contract expired next quarter in case the trade date is in
%the 2nd half of a quarter month.i.e.mar,jun,sep and dec
if mod(curr_mm,3)==0
    if curr_mm<10
        mm_str = ['0',num2str(curr_mm)];
    else
        mm_str = num2str(curr_mm);
    end
    first_month_date = datenum([yy_str,mm_str,'01'],'yyyymmdd');
    wkd = weekday(first_month_date);
    if wkd==6
        first_friday_date = first_month_date;
    else
        if wkd==7
            first_friday_date = first_month_date+6;
        else
            first_friday_date = first_month_date+6-wkd;
        end
    end
    second_friday_date = first_friday_date+7;
    if curr_dd > second_friday_date
        curr_mm = curr_mm + 3;
        if curr_mm > 12
            curr_mm = curr_mm-12;
            curr_yy = curr_yy+1;
        end
    end
end

%number of contracts traded in total
if init_yy < curr_yy
    n = ceil((12-init_mm+1)/3)+...  %contracts for the 1st year
        (curr_yy-1-init_yy)*4+...   %contracts between 2nd year and last year
        floor((curr_mm)/3)+...      %contracts before this month in this year
        3;                          %listed contracts
    if mod(curr_mm,3) == 0
        n = n - 1;
    end
%generally the code will never execute in the following part
else
    if curr_mm <= init_mm
        n = 3;
    else
        n = ceil((curr_mm-init_mm)/3)+3;
    end
end

contracts = cell(n,1);
i=1;
while i<=n
    mm = (i-1)*3+init_mm;
    if mod(mm,12)==0
        yy=init_yy+mm/12-1;
    else
        yy=init_yy+floor(mm/12);
    end
    yy_str=num2str(yy);
    mm=mod(mm,12);
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

%it seems that the issue has been fixed in Bloomberg since June/2017 so we
%just comment it out
% if ~iswind && strcmpi(assetName,'govtbond_5y')
%     for i = 1:length(contracts)
%         if strcmpi(contracts{i},'TFCH14 Comdty')
%             contracts{i} = 'TFCH4 Comdty';
%         end
%     end
% end