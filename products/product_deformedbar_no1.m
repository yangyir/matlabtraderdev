function product = product_deformedbar_no1(varargin)
    %
    %function to return the product with deformed bar undelier
    %we call it NO.1 and products detail shall be updated
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ProductIssueDate',{},@(x) validateattributes(x,{'char','numeric'},{},'ProductIssueDate'));
    p.parse(varargin{:});
    
    issuedate = p.Results.ProductIssueDate;
    if isempty(issuedate)
        %default is the previous business date
        issuedate = businessdate(today,-1);
    end
    
    %products elements
    assetname = 'deformed bar';
    underlyingasset = cAsset('AssetName',assetname);
    %roll every-month for half a year
    tenors = {'1m';'2m';'3m';'4m';'5m';'6m'};
    %the deliver deformed bar amount in tons are fixed by the client
    notional = [390;120;110;180;185;80];
    %the otm strike of 2800 is set up by the client
    otmstrike = 2800;
    %client buy call spread, i.e. long call and a lower strike and sell
    %call at a higher strike
    opttype = 'call';
    %
    %
    %long/short tenors
    expirytenors = [tenors;tenors];
    %long/short notional
    notional = [notional;-notional];
    nOpt = size(expirytenors,1);
    expirydates = zeros(nOpt,1);
    underliers = cell(nOpt,2);
    
    for i = 1:nOpt
        %calculate expiry dates
        expirydates(i) = dateadd(issuedate,expirytenors{i},1,1);
        %we cut-off the futures at 1705 ATM
        for j = 1:size(underlyingasset.ContractList,1)-1
            if underlyingasset.ContractList{j,3} - expirydates(i) > 33
                break
            end
        end
        underliers{i,2} = j;
    end
    
    %find the unique underlying futures
    answer = cell2mat(underliers(:,2));
    idx = unique(answer);
    futures = cell(length(idx),1);
    for i = 1:size(futures,1)
        windcode = underlyingasset.ContractList{idx(i),2};
        for j = 1:length(windcode)
            answer = str2double(windcode(j));
            if ~isnan(answer)
                break
            end
        end
        tenor = windcode(j:end-4);
        futures{i,1} = cContract('assetname',assetname,'tenor',tenor);
    end
    
    %pop-up the underliers table for the options
    for i = 1:nOpt
        for j = 1:size(idx,1)
            if underliers{i,2} == idx(j)
                break
            end
        end
        underliers{i,1} = futures{j,1};
        underliers{i,2} = j;
    end
    
    tseod = cell(size(futures,1),1);
    freq = '1d';
    fields = {'close';'volume'};
    
    %download timeseries data
    for i = 1:size(futures,1);
        try
            tsobj = futures{i}.getTimeSeriesObj('connection','bloomberg','frequency',freq);
        catch
            tsobjs = futures{i}.initTimeSeries('connection','bloomberg','datasource','internet','frequency',freq);
            tsobj = tsobjs{1};
        end
        
        ld = datenum(tsobj.getLastDateEntry);
        if ld < issuedate
            futures{i}.updateTimeSeries('connection','bloomberg','frequency',freq);
        end
        
        tseod{i} = futures{i}.getTimeSeries('connection','bloomberg','fields',fields,'frequency',freq);
    end 

    refspot = zeros(nOpt,2);

    for i = 1:nOpt
        data = tseod{underliers{i,2}};
        refspot(i,:) = timeseries_window(data(:,1:2),'fromdate',issuedate,'todate',issuedate);
    end


    strikes = zeros(nOpt,2);
    for i = 1:nOpt
        if i <= nOpt/2
            strikes(i) = refspot(i,2);
        else
            strikes(i) = otmstrike;
        end
    end

    vanillas = cell(nOpt,1);

    for i = 1:nOpt
        vanillas{i} = CreateObj(['vanilla_',num2str(i)],'SECURITY',...
            'securityname','european','issuedate',issuedate,'expirydate',expirydates(i),...
            'strike',strikes(i),'underlier',underliers{i},'optiontype',opttype,...
            'referencespot',refspot(i,2),'notional',notional(i)); 
    end
    
    productvolume = 0;
    productnotional = 0;
    for i = 1:size(vanillas,1)
        if vanillas{i}.Notional > 0
            productnotional = productnotional + vanillas{i}.Notional*vanillas{i}.ReferenceSpot;
            productvolume = productvolume + vanillas{i}.Notional;
        end
    end
    
    nunderlier = size(futures,1);
    underlyings = futures;
    
    %a book is a collection of vanillas with the same underlier
    books = cell(nunderlier,1);
    counts = zeros(nunderlier,1);
    
    
    for i = 1:nOpt
        for j = 1:nunderlier
            if strcmpi(vanillas{i}.Underlier.WindCode,futures{j}.WindCode)
                counts(j) = counts(j)+1;
            end
        end
    end
    
    for i = 1:nunderlier
        book = cell(counts(i),1);
        idx = 0;
        for j = 1:nOpt
            if strcmpi(vanillas{j}.Underlier.WindCode,futures{i}.WindCode)
                idx = idx+1;
                book{idx} = vanillas{j};
            end
        end
        books{i} = book;
    end
    
    product = cProduct('Books',books,...
        'Securities',vanillas,...
        'Underliers',underlyings,...
        'Notional',productnotional,...
        'Volume',productvolume,...
        'Name','deformedbar_no1',...
        'IssueDate',issuedate);
end