function product = product_strangleonfutures(varargin)
    %
    % function to return the product of a strangle on a futures
    % strangle:the simultaneous buying or selling of out-of-the-money put
    % and an out-of-the-money call, with the same expiration
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ProductName','vanilla',@(x) validateattributes(x,{'char'},{},'ProductName'));
    p.addParameter('ProductIssueDate',{},@(x) validateattributes(x,{'char','numeric'},{},'ProductIssueDate'));
    p.addParameter('Underlying',{},@(x) validateattributes(x,{'cContract'},{},'Underlying'));
    p.addParameter('LowerStrike',{},@isnumeric);
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
        error('product_bullspreadonfutures:underlying is missing!')
    end
    
    lowerstrike = p.Results.LowerStrike;
    if isempty(lowerstrike)
        error('product_bullspreadonfutures:lower strike is missing!')
    end
    
    upperstrike = p.Results.UpperStrike;
    if isempty(upperstrike)
        error('product_bullspreadonfutures:upper strike is missing!')
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
    
    vanillas = cell(2,1);
    vanillas{1} = CreateObj(productname,'security',...
        'SecurityName','European',...
        'Underlier',underlying,...
        'OptionType','Put',...
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
    
    books = cell(1,1);
    book = vanillas;
    books{1} = book;
   
    underlyings = cell(1,1);
    underlyings{1} = underlying;
    productnotional = unit * refspot;
    productvolume = unit;
      
    product = cProduct('Books',books,...
        'Securities',vanillas,...
        'Underliers',underlyings,...
        'Notional',productnotional,...
        'Volume',productvolume,...
        'Name',productname,...
        'IssueDate',issuedate);
    
end