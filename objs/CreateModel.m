function model =  CreateModel(modelHandle,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('ObjHandle',@ischar);
    p.addParameter('ModelName',{},...
        @(x) validateattributes(x,{'char'},{},'','ModelName'));
    p.parse(modelHandle,varargin{:});
    objhandle = p.Results.ObjHandle;
    modelname = p.Results.ModelName;
    
    if strcmpi(modelname,'CCBSMC')
        model = cModelAnalytic(objhandle,varargin{:});
    elseif strcmpi(modelname,'CCBX')
        model = cModelX(objhandle,varargin{:});
    else
        error('model not implemented')
    end
end