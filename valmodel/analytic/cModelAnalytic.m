classdef cModelAnalytic < cModel
    %cal
    properties (Access = public)
        %other parameters to add for varswap pricing and others
    end
    
    methods %SET/GET methods                
    end
    
    methods (Access = public)
        function obj = cModelAnalytic(objhandle,varargin)
            obj = init(obj,objhandle,varargin{:});
        end
    end
    
    methods (Access = private)
        function obj = init(obj,objhandle,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('ObjHandle',@ischar);
            p.addParameter('ModelName','CCBSMC',...
                @(x) validateattributes(x,{'char'},{},'','ModelName'));
            p.addParameter('CalcIntrinsic',0,...
                @(x) validateattributes(x,{'numeric'},{},'','CalcIntrinsic'));
            p.addParameter('ExtraResults',0,...
                @(x) validateattributes(x,{'numeric'},{},'','ExtraResults'));
            p.parse(objhandle,varargin{:});
            obj.ObjHandle = p.Results.ObjHandle;
            obj.ObjType = 'MODEL';
            obj.ModelName = p.Results.ModelName;
            
            if ~strcmpi(obj.ModelName,'CCBSMC')
                error('cModelAnalytic:model name must be "CCBSMC"!')
            end
            obj.ExtraResults = p.Results.ExtraResults;
            if ~(obj.ExtraResults == 0 || obj.ExtraResults == 1)
                error('cModelAnalytic:extra results must be either 0 or 1!');
            end 
            obj.CalcIntrinsic = p.Results.CalcIntrinsic;
            if ~(obj.CalcIntrinsic == 0 || obj.CalcIntrinsic == 1)
                error('cModelAnalytic:CalcIntrinsic must be either 0 or 1');
            end
            
        end
    end
end