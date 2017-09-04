classdef cLocalVol < cVol
    %local vol class
    properties
        FlatVol
        InterpolationMethodK
        ExtrapolationMethodK
    end
    
    methods (Access = public)
        function obj = cLocalVol(objhandle,varargin)
            obj = init(obj,objhandle,varargin{:});
        end
        %constructor
    end
    
    methods (Access = public)
        function v = getVol(obj,S,t)
            if strcmpi(obj.VolType,'FlatVol')
                v = obj.FlatVol;
                if v == -9.99
                    error('cLocalVol:getVol:invalid flat vol!')
                end
            else
                error('cLocalVol:getvol:VolType not implemented!')
            end
        end
    end
    
    methods (Access = private)
        function obj = init(obj,objhandle,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('ObjHandle',@ischar);
            p.addParameter('VolType',{},@ischar);
            p.addParameter('InterpolationMethodK','linear',@ischar);
            p.addParameter('ExtrapolationMethodK','none',@ischar);
            p.addParameter('FlatVol',-9.99,@isnumeric);
            p.addParameter('AssetName',{},@ischar);
            
            p.parse(objhandle,varargin{:});
            obj.ObjHandle = p.Results.ObjHandle;
            obj.ObjType = 'VOL';
            obj.VolName = 'LOCALVOL';
            obj.VolType = p.Results.VolType;
            if ~(strcmpi(obj.VolType,'FlatVol') || strcmpi(obj.VolType,'SkewVol') ...
                    || strcmpi(obj.VolType,'SkewParametricVol'))
                error('cLocalVol:init:invalid VolType input!')
            end
            
            %for now only
            if ~strcmpi(obj.VolType,'FlatVol')
                error('cLocalVol:init:todo "only FlatVol" is supported!')
            end
                        
            obj.InterpolationMethodK = p.Results.InterpolationMethodK;
            %sanity check of InterpolationMethod
            if ~(strcmpi(obj.InterpolationMethodK,'linear') || ...
                    strcmpi(obj.InterpolationMethodK,'piecewise-constant'))
                error('cLocalVol:init:invalid InterpolationK input!')
            end
            
            %sanity check of ExtrapolationMethod
            obj.ExtrapolationMethodK = p.Results.ExtrapolationMethodK;
            if ~(strcmpi(obj.ExtrapolationMethodK,'none') || ...
                    strcmpi(obj.ExtrapolationMethodK,'flat'))
                %todo:other methods to be added
                error('cLocalVol:init:invalid ExtrapolationK input!')
            end
            
            obj.AssetName = p.Results.AssetName;
            obj.FlatVol = p.Results.FlatVol;
            
            
            
            
            
        end
        %function 'init'
    end
    
    
end