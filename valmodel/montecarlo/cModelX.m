classdef cModelX < cModel
    properties
        NumSims
        NumRuns
        VarianceReduction
        UseBusinessCalendar
    end
    
    methods
        function obj = cModelX(objhandle,varargin)
            obj = init(obj,objhandle,varargin{:});
        end
    end
    
    methods (Access = private)
        function obj = init(obj,objhandle,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('ObjHandle',@ischar)
            p.addParameter('ModelName','CCBX',...
                @(x) validateattributes(x,{'char'},{},'','ModelName'));
            p.addParameter('CalcIntrinsic',0,...
                @(x) validateattributes(x,{'numeric'},{},'','CalcIntrinsic'));
            p.addParameter('ExtraResults',0,...
                @(x) validateattributes(x,{'numeric'},{},'','ExtraResults'));
            p.addParameter('NumberOfSims',1,@isnumeric);
            p.addParameter('NumberOfRuns',1,@isnumeric);
            p.addParameter('VarianceReduction','None',@ischar);
            p.addParameter('UseBusinessCalendar',false,@islogical);
            p.parse(objhandle,varargin{:});
            obj.ObjHandle = p.Results.ObjHandle;
            obj.ObjType = 'MODEL';
            
            obj.ModelName = p.Results.ModelName;
            if ~strcmpi(obj.ModelName,'CCBX')
                error('cModelX:model name must be "CCBX"!');
            end
            
            obj.ExtraResults = p.Results.ExtraResults;
            if ~(obj.ExtraResults == 0 || obj.ExtraResults == 1 )
                error('cModelX:ExtraResults must be either 0 or 1!');
            end
            
            obj.CalcIntrinsic = p.Results.CalcIntrinsic;
            if ~(obj.CalcIntrinsic == 0 || obj.CalcIntrinsic == 1)
                error('cModelX:CalcIntrinsic must be either 0 or 1');
            end
            
            obj.NumSims = p.Results.NumberOfSims;
            obj.NumRuns = p.Results.NumberOfRuns;
            obj.VarianceReduction = p.Results.VarianceReduction;
            
            if ~(strcmpi(obj.VarianceReduction,'None') || ...
                    strcmpi(obj.VarianceReduction,'Antithetic'))
                error('cModelX:VarianceReduction must be either "NONE" or "ANTITHETIC"');
            end
            
            obj.UseBusinessCalendar = p.Results.UseBusinessCalendar;
            
        end
    end
end