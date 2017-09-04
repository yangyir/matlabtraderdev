classdef cProduct
    properties
        Books
        Securities
        Underliers
        Notional
        Volume
        Name
        IssueDate
    end
    
    properties (GetAccess = public, SetAccess = private, Dependent)
        ExpiryDate
    end
    
    methods
        function expiry = get.ExpiryDate(obj)
            if strcmpi(obj.Securities{1}.SecurityName,'European')
                expiry = datenum(obj.Securities{1}.ExpiryDate);
            else
                error('not implemented yet!')
            end
            
            for i = 2:size(obj.Securities,1)
                if strcmpi(obj.Securities{i}.SecurityName,'European')
                    if datenum(obj.Securities{i}.ExpiryDate) > expiry
                        expiry = datenum(obj.Securities{i}.ExpiryDate);
                    end
                else
                    error('not implemented yet!')
                end
            end
        end
        %
    end
    
    methods
        function obj = cProduct(varargin)
            obj = init(obj,varargin{:});
        end
        %
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Books',{},@iscell);
            p.addParameter('Securities',{},@iscell);
            p.addParameter('Underliers',{},@iscell);
            p.addParameter('Notional',{},@isnumeric);
            p.addParameter('Volume',{},@isnumeric);
            p.addParameter('Name',{},@ischar);
            p.addParameter('IssueDate',{},@(x) validateattributes(x,{'numeric','char'},{},'','IssueDate'));
            p.parse(varargin{:});
            obj.Books = p.Results.Books;
            obj.Securities = p.Results.Securities;
            obj.Underliers = p.Results.Underliers;
            nBook = size(obj.Books,1);
            nUnderlier = size(obj.Underliers,1);
            if nBook ~= nUnderlier
                error('cProduct:init:invalid input of Books or Underliers')
            end
            
            for i = 1:nUnderlier
                if ~isa(obj.Underliers{i},'cContract')
                    error('cProduct:init:invalid input of Underliers')
                end
            end
            
            for i = 1:size(obj.Securities,1)
                if ~isa(obj.Securities{i},'cSecurity')
                    error('cProduct:init:invalid input of Securities')
                end
            end
            
            obj.Notional = p.Results.Notional;
            obj.Volume = p.Results.Volume;
            obj.Name = p.Results.Name;
            obj.IssueDate = p.Results.IssueDate;
        end
        %
    end
end