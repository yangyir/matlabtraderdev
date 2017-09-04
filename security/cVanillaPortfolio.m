classdef cVanillaPortfolio < cSecurity
    properties (Access = public)
        Vanillas  %cell of cVanilla
        UseFlags
    end
    
    methods
        function obj = cVanillaPortfolio(objhandle,varargin)
            obj = init(obj,objhandle,varargin{:});
        end
    end
    
    methods (Access = public)
        function res = instruments(obj)
            n = length(obj.Vanillas);
            if n == 0
                res = {};
                return
            end
            res = cell(n,1);
            count = 1;
            res{count,1} = obj.Vanillas{1}.Underlier;
            for i = 2:n
                foundFlag = false;
                for j = 1:count
                    if strcmpi(obj.Vanillas{i}.Underlier.BloombergCode,...
                            res{j,1}.BloombergCode)
                        foundFlag = true;
                        break
                    end
                end
                if foundFlag
                    continue;
                else
                    count = count+1;
                    res{count,1} = obj.Vanillas{i}.Underlier;
                end
            end
            res = res(1:count,1);
        end
        
        
        function idx = find(obj,vanilla)
            idx = 0;
            if ~isa(vanilla,'cVanilla')
                error('cVanillaPortfolio:add:invalid input')
            end
            for i = 1:length(obj.Vanillas)
                if strcmpi(obj.Vanillas{i}.ObjHandle,vanilla.ObjHandle)
                    idx = i;
                    return
                end
            end
        end
        %end of find function
        
        function obj = add(obj,vanilla)
            if ~isa(vanilla,'cVanilla')
                error('cVanillaPortfolio:add:invalid input')
            end
            if isempty(obj.Vanillas)
                obj.Vanillas = {vanilla};
                obj.UseFlags = 1;
            else
                n = length(obj.Vanillas)+1;
                vanillas = cell(n,1);
                useflags = ones(n,1);
                vanillas(1:n-1,1) = obj.Vanillas;
                vanillas{n} = vanilla;
                useflags(1:n-1,1) = obj.UseFlags;
                obj.Vanillas = vanillas;
                obj.UseFlags = useflags;
            end
        end
        %end of add function
        
        function obj = remove(obj,vanilla)
            if ~isa(vanilla,'cVanilla')
                error('cVanillaPortfolio:add:invalid input')
            end
            if isempty(obj.Vanillas)
                error('cVanillaPortfolio:empty vanilla portfolio')
            end
            idx = find(obj,vanilla);
            if idx < 1
                error('cVanillaPortfolio:vanilla not found')
            end
            n = length(obj.Vanillas);
            if n == 1
                obj.Vanillas = {};
                obj.UseFlags = [];
            else
                vanillas = cell(n-1,1);
                useflags = zeros(n-1,1);
                vanillas(1:idx-1,1) = obj.Vanillas(1:idx-1,1);
                vanillas(idx:end,1) = obj.Vanillas(idx+1:end,1);
                useflags(1:idx-1,1) = obj.UseFlags(1:idx-1,1);
                useflags(idx:end,1) = obj.UseFlags(idx+1:end,1);
                obj.Vanillas = vanillas;
                obj.UseFlags = useflags;
            end
        end
        %end of remove function
        
        function [bbgcodes,symbols] = uniqueunderlier(obj)
            if isempty(obj.Vanillas)
                bbgcodes = {};
                symbols = {};
            else
                n = length(obj.Vanillas);
                codes = cell(n,2);
                for i = 1:n
                    codes{i,1} = obj.Vanillas{i}.Underlier.BloombergCode;
                    codes{i,2} = obj.Vanillas{i}.Underlier.Symbol;
                end
                bbgcodes = unique(codes(:,1));
                symbols = unique(codes(:,2));
            end
        end
        %end of uniqueunderlier function
            
        function obj = setuseflag(obj,idx,use)
            n = length(obj.Vanillas);
            if idx < -1 || idx > n || idx == 0
                error('cVanillaPortfolio:setuseflag:invalid idx input')
            end
            if ~(use == 0 || use == 1)
                error('cVanillaPortfolio:setuseflag:invalid use input')
            end
            
            useflag = obj.UseFlags;
            if idx == -1
                useflag(:,1) = use;
            else
                useflag(idx,1) = use;
            end
            obj.UseFlags = useflag;
        end
        %end of setuseflag function
        
    end
    
    methods (Access = private)
        function obj = init(obj,objhandle,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('ObjHandle',@ischar);
            p.parse(objhandle,varargin{:});
            obj.ObjHandle = p.Results.ObjHandle;
            obj.ObjType = 'SECURITY';
            obj.SecurityName = 'VANILLAPORTFOLIO';
            obj.Vanillas = {};
            obj.UseFlags = [];
        end
    end
    
end

