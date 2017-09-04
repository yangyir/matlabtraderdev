classdef cVanillaPortfolio
    %class of portfolio of vanilla (european) options
    %note:
    %1.the option shall have the same underlier
    %2.the class itself is used for trading only but not for derivative
    %pricing,i.e.the valuation is done using the 'Financial Instrument
    %Toolbox' in Matlab
    
    properties (Access = public)
        Name
        Underlier
        Strikes
        SettleDates
        ExpiryDates
        OptionTypes
        Notionals
        ReferenceSpots
    end
    
    %constructor methods
    methods 
        function obj = cVanillaPortfolio(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods (Access = public)
        function obj = addvanilla(obj,varargin)
        end
        
        function obj = removevanilla(obj,varargin)
            [flag,idx] = findvanilla(obj,varargin{:});
            if ~flag
                error('removevanilla:invalid input')
            else
                nStrikes = length(obj.Strikes);
                if nStrikes == 1
                    obj.Underlier = {};
                    obj.Strikes = [];
                    obj.SettleDates = [];
                    obj.ExpiryDates = [];
                    obj.OptionTypes = {};
                    obj.Notionals = [];
                    obj.ReferenceSpots = [];
                else
                    if idx == 1
                        strikes = obj.Strikes(2:end,1);
                        settles = obj.SettleDates(2:end,1);
                        expiries = obj.ExpiryDates(2:end,1);
                        optTypes = obj.OptionTypes(2:end,1);
                        notionals = obj.Notionals(2:end,1);
                        if ~isempty(obj.ReferenceSpots)
                            refSpots = obj.ReferenceSpots(2:end,1);
                        else
                            refSpots = [];
                        end
                    else
                        strikes = [obj.Strikes(1:idx-1,1);obj.Strikes(idx+1:end,1)];
                        settles = [obj.SettleDates(1:idx-1,1);obj.SettleDates(idx+1:end,1)];
                        expiries = [obj.ExpiryDates(1:idx-1,1);obj.ExpiryDates(idx+1:end,1)];
                        optTypes = [obj.OptionTypes(1:idx-1,1);obj.OptionTypes(idx+1:end,1)];
                        notionals = [obj.Notionals(1:idx-1,1);obj.Notionals(idx+1:end,1)];
                        if ~isempty(obj.ReferenceSpots)
                            refSpots = [obj.ReferenceSpots(1:idx-1,1);obj.ReferenceSpots(idx+1:end,1)];
                        else
                            refSpots = [];
                        end
                    end
                    obj.Strikes = strikes;
                    obj.SettleDates = settles;
                    obj.ExpiryDates = expiries;
                    obj.OptionTypes = optTypes;
                    obj.Notionals = notionals;
                    obj.ReferenceSpots = refSpots;
                        
                end
            end
        end
    end
        
    
    methods (Access = private)
        function [flag,msg] = isvalid(obj)
            nStrikes = length(obj.Strikes);
            if length(obj.SettleDates) ~= nStrikes
                flag = false;
                msg = 'size mismatch between settle dates and strikes';
                return
            end
            
            if length(obj.ExpiryDates) ~= nStrikes
                flag = false;
                msg = 'size mismatch between expiry dates and strikes';
                return
            end
            
            if ischar(obj.OptionTypes) && nStrikes > 1
                flag = false;
                msg = 'size mismatch between option types and strikes';
                return
            end
            
            if ischar(obj.OptionTypes) && ~(strcmpi(obj.OptionTypes,'call')||...
                    strcmpi(obj.OptionTypes,'put')||...
                    strcmpi(obj.OptionTypes,'straddle'))
                flag = false;
                msg = 'invalid option type';
                return
            end
            
            if iscell(obj.OptionTypes) && length(obj.OptionTypes) ~= nStrikes
                flag = false;
                msg = 'size mismatch between option types and strikes';
                return
            end
            
            for i = 1:nStrikes
                if obj.SettleDates(i) > obj.ExpiryDates(i)
                    flag = fales;
                    msg = 'settle dates beyond expiry dates';
                    return
                end
                
                
                if iscell(obj.OptionTypes) && ...
                        ~(strcmpi(obj.OptionTypes{i},'call') ||...
                        strcmpi(obj.OptionTypes{i},'put') ||...
                        strcmpi(obj.OptionTypes{i},'straddle'))
                    flag = false;
                    msg = 'invalid option type';
                    return
                end
                
                
            end
            
            if length(obj.Notionals) ~= nStrikes
                flag = false;
                msg = 'size mismatch between notional and strikes';
                return
            end
            
            if ~isempty(obj.ReferenceSpots) && ...
                    length(obj.ReferenceSpots) ~= nStrikes
                flag = false;
                msg = 'size mismatch between reference spots and strikes';
                return
            end
            
            flag = true;
            msg = 'valid vanilla portfolio';
            
        end
        %end of function 'isvalid'
        
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Name','VanillaPortfolio',@ischar);
            p.addParameter('Underlier',{},...
                @(x)validateattributes(x,{'cContract','struct'},{},'','Underlier'));
            p.addParameter('Strikes',{},@isnumeric);
            p.addParameter('SettleDates',{},...
                @(x)validateattributes(x,{'numeric','char','cell'},{},'','SettleDates'));
            p.addParameter('ExpiryDates',{},...
                @(x)validateattributes(x,{'numeric','char','cell'},{},'','ExpiryDates'));
            p.addParameter('OptionTypes',{},...
                @(x)validateattributes(x,{'char','cell'},{},'','OptionTypes'));
            p.addParameter('Notionals',{},@isnumeric);
            p.addParameter('ReferenceSpots',{},@isnumeric);
            p.parse(varargin{:});
            obj.Name = p.Results.Name;
            obj.Underlier = p.Results.Underlier;
            obj.Strikes = p.Results.Strikes;
            obj.SettleDates = datenum(p.Results.SettleDates);
            obj.ExpiryDates = datenum(p.Results.ExpiryDates);
            obj.OptionTypes = p.Results.OptionTypes;
            obj.Notionals = p.Results.Notionals;
            obj.ReferenceSpots = p.Results.ReferenceSpots;
            
            [flag,msg] = isvalid(obj);
            if ~flag
                error(msg);
            end
            
        end
        %end of function 'init'
        
        function [flag,idx] = findvanilla(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Strike',{},@isnumeric);
            p.addParameter('SettleDate',{},...
                @(x)validateattributes(x,{'numeric','char'},{},'','SettleDate'));
            p.addParameter('ExpiryDate',{},...
                @(x)validateattributes(x,{'numeric','char'},{},'','ExpiryDate'));
            p.addParameter('OptionType',{},@ischar);
            p.addParameter('Notional',{},@isnumeric);
            p.addParameter('ReferenceSpot',{},@isnumeric);
            p.parse(varargin{:});
            k = p.Results.Strike;
            T0 = datenum(p.Results.SettleDate);
            TN = datenum(p.Results.ExpiryDate);
            optType = p.Results.OptionType;
            notional = p.Results.Notional;
            refSpot = p.Results.ReferenceSpot;
            
            nStrikes = length(obj.Strikes);
            if nStrikes == 1
                if k == obj.Strikes &&...
                        T0 == obj.SettleDates &&...
                        TN == obj.ExpiryDates &&...
                        strcmpi(optType,obj.OptionTypes) &&...
                        notional == obj.Notionals
                    if isempty(refSpot) && isempty(obj.ReferenceSpots)
                        flag = true;
                        idx = 1;
                    elseif ~isempty(refSpot) && ~isempty(obj.ReferenceSpots)
                        flag = true;
                        idx = 1;
                    else
                        flag = false;
                        idx = 0;
                    end
                else
                    flag = false;
                    idx = 0;
                end
            else
                for i = 1:nStrikes
                    if k == obj.Strikes(i) &&...
                            T0 == obj.SettleDates(i) &&...
                            TN == obj.ExpiryDates(i) &&...
                            strcmpi(optType,obj.OptionTypes{i}) &&...
                            notional == obj.Notionals{i}
                end
            end
            
        end
        
    end
    
end

