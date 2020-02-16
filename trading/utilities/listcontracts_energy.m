function contracts = listcontracts_energy(assetName,varargin)
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
if strcmpi(assetName,'pta')
    init_mm = 5;
    init_yy = 2007;
elseif strcmpi(assetName,'lldpe')
    init_mm = 1;
    init_yy = 2008;
elseif strcmpi(assetName,'pp')
    init_mm = 5;
    init_yy = 2014;
elseif strcmpi(assetName,'methanol')
    init_mm = 5;
    init_yy = 2012;
elseif strcmpi(assetName,'thermal coal')
    init_mm = 1;
    init_yy = 2014;
elseif strcmpi(assetName,'crude oil')
    init_mm = 9;
    init_yy = 2018;
else
    error('listcontracts_energy:invalid asset name');
end

curr_dd = today;
curr_yy = year(curr_dd);
curr_mm = month(curr_dd);

%number of contracts traded in total
if ~strcmpi(assetName,'crude oil')
    n = ceil((12-init_mm)/4)+...    %contracts first year
        (curr_yy-1-init_yy)*3+...   %contracts between next year and last year
        ceil(curr_mm/4)+...         %contracts traded so far this year
        +3;                         %contracts listed from this month
else
    if init_yy < curr_yy
%         n = (12-init_mm+1)+...          %contracts for the first year
%             (curr_yy-1-init_yy)*12+...  %contracts between the 2nd and last year
%             curr_mm+...                 %contracts for this year
%             3;                          %now listed and activly traded
        n = 8;
    else
        n = (curr_mm-init_mm+1)+12;
    end
end

contracts = cell(n,1);
i=1;
while i<=n
    if ~strcmpi(assetName,'crude oil')
        mm = (i-1)*4+init_mm;
    else
%         mm = i+init_mm-1;
        if i == 1
            mm = 9;
        elseif i == 2
            mm = 12;
        elseif i == 3
            mm = 13;
        elseif i == 4
            mm = 15;
        elseif i == 5
            mm = 16;
        else
            mm = i+20;
        end
    end
    if mod(mm,12)==0
        yy = init_yy+mm/12-1;
    else
        yy = init_yy+floor(mm/12);
    end
    yy_str = num2str(yy);
    mm = mod(mm,12);
    if mm==0
        mm = 12;
    end;
    if mm<10
        mm_str = ['0',num2str(mm)];
    else
        mm_str = num2str(mm);
    end
    if iswind
        if ~strcmpi(exchange,'.CZC')
            contracts{i,1} = [wcode,yy_str(end-1:end),mm_str,exchange];
        else
%             if yy>2010
%                 contracts{i,1} = [wcode,yy_str(end),mm_str,exchange];
%             else
%                 contracts{i,1} = [wcode,yy_str(end-1:end),mm_str,exchange];
%             end
            contracts{i,1} = [wcode,yy_str(end-1:end),mm_str,exchange];
        end
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