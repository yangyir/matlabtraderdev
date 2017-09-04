function product = product_butterflyonfutures(varargin)
    %
    % function to return the product of a butterfly on a futures
    % butterfly:buy ITM(in the money) and OTM(out of the money) call, sell
    % two at the money calls, or vice versa
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ProductName','vanilla',@(x) validateattributes(x,{'char'},{},'ProductName'));
    p.addParameter('ProductIssueDate',{},@(x) validateattributes(x,{'char','numeric'},{},'ProductIssueDate'));
    p.addParameter('Underlying',{},@(x) validateattributes(x,{'cContract'},{},'Underlying'));
    p.addParameter('LowerStrike',{},@isnumeric);
    p.addParameter('MiddleStrike',{},@isnumeric);
    p.addParameter('UpperStrike',{},@isnumeric);
    p.addParameter('Unit',{},@(x) validateattributes(x,{'numeric'},{},'Unit'));
    p.addParameter('ExpiryDate','1m',@(x) validateattributes(x,{'numeric','char'},{},'ExpiryDate'));
   
    p.parse(varargin{:});
    productname = p.Results.ProductName;
    issuedate = p.Results.ProductIssueDate;
    if isempty(issuedate)
        issuedate = businessdate(today,-1);
    end
    issuedate = datenum(issuedate);
    underlying = p.Results.Underlying;
    if isempty(underlying)
        error('product_butterflyonfutures:underlying is missing!')
    end
    
    lowerstrike = p.Results.LowerStrike;
    if isempty(lowerstrike)
        error('product_butterflyonfutures:lower strike is missing!')
    end
    
    upperstrike = p.Results.UpperStrike;
    if isempty(upperstrike)
        error('product_butterflyonfutures:upper strike is missing!')
    end
    
    middlestrike = p.Results.MiddleStrike;
    if isempty(middlestrike)
        error('product_butterflyonfutures:middle strike is missing!')
    end
    
    unit = p.Results.Unit;
    %default the minimum unit of the option contract to the contract size
    %of the underlying futures
    if isempty(unit)
        unit = underlying.ContractSize;
    end
    expirydate = p.Results.ExpiryDate;
    if ~isnumeric(expirydate)
        try
            expirydate = datenum(expirydate);
        catch
            %datenum failed
            expirydate = dateadd(issuedate,expirydate,1);
        end
    end
    
    %sanity check to make sure that the option's expiry date is on or
    %before the expiry of the underlying futures
    if expirydate > underlying.Expiry
        error('product_vanillaonfutures:expiry of vanillas shall be on or before the expiry of the underlying futures!')
    end
    
    try
        data = underlying.getTimeSeries('connection','bloomberg',...
            'fields',{'close','volume'},...
            'frequency','1d',...
            'fromdate',issuedate,...
            'todate',issuedate);
        if data(end,1) == issuedate
            refspot = data(end,2);
        else
            %data not updated
            underlying.updateTimeSeries('connection','bloomberg','frequency','1d');
            data = underlying.getTimeSeries('connection','bloomberg',...
                'fields',{'close','volume'},...
                'frequency','1d',...
                'fromdate',issuedate,...
                'todate',issuedate);
            if data(end,1) ~= issuedate
                error('product_vanillaonfutures:underlying not updated or expired!')
            end
            refspot = data(end,2);
        end
    catch
        %getTimeSeries method failed
        underlying.initTimeSeries('connection','bloomberg','frequency','1d',...
            'datasource','internet');
        data = underlying.getTimeSeries('connection','bloomberg',...
            'fields',{'close','volume'},...
            'frequency','1d',...
            'fromdate',issuedate,...
            'todate',issuedate);
        refspot = data(end,2);
    end
    
    vanillas = cell(3,1);
    vanillas{1} = CreateObj(productname,'security',...
        'SecurityName','European',...
        'Underlier',underlying,...
        'OptionType','Call',...
        'Strike',lowerstrike,...
        'IssueDate',issuedate,...
        'ExpiryDate',expirydate,...
        'Notional',unit,...
        'ReferenceSpot',refspot);
    
    vanillas{2} = CreateObj(productname,'security',...
        'SecurityName','European',...
        'Underlier',underlying,...
        'OptionType','Call',...
        'Strike',upperstrike,...
        'IssueDate',issuedate,...
        'ExpiryDate',expirydate,...
        'Notional',unit,...
        'ReferenceSpot',refspot);
    
    vanillas{3} = CreateObj(productname,'security',...
        'SecurityName','European',...
        'Underlier',underlying,...
        'OptionType','Call',...
        'Strike',middlestrike,...
        'IssueDate',issuedate,...
        'ExpiryDate',expirydate,...
        'Notional',-2.0*unit,...
        'ReferenceSpot',refspot);
    
    books = cell(1,1);
    book = vanillas;
    books{1} = book;
   
    underlyings = cell(1,1);
    underlyings{1} = underlying;
    productnotional = 2.0*unit * refspot;
    productvolume = 2.0*unit;
      
    product = cProduct('Books',books,...
        'Securities',vanillas,...
        'Underliers',underlyings,...
        'Notional',productnotional,...
        'Volume',productvolume,...
        'Name',productname,...
        'IssueDate',issuedate);
    
end