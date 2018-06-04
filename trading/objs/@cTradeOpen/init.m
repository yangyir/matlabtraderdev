function obj = init(obj,varargin)
p = inputParser;
p.CaseSensitive = fasle;
p.KeepUnmatched = true;
p.addParameter('CounterName','',@ischar);
p.addParameter('CTPCode','',@ischar);
p.addParameter('OpenTime',[],@isnumeric);
p.addParameter('OpenDirection',[],@isnumeric);
p.addParameter('OpenPrice',[],@isnumeric);
p.addParameter('TargetPrice',[],@isnumeric);
p.addParameter('StoplossPrice',[],@isnumeric);
p.addParameter('RiskManagementMethod','standard',@ischar);
p.parse(varargin{:});
obj.countername_ = p.Results.CounterName;
obj.ctpcode_ = p.Results.CTPCode;
if ~isempty(obj.ctpcode_)
    instrument = code2instrument(obj.ctpcode_);
    obj.instrument_ = instrument;
end
obj.opendatetime1_ = p.Results.OpenTime;
if ~isempty(obj.opendatetime1_)
    obj.opendatetime2_ = datestr(obj.opendatetime1_,'yyyy-mm-dd HH:MM:SS');
end
obj.opendirection_ = p.Results.OpenDirection;
obj.openprice_ = p.Results.OpenPrice;
obj.targetprice_= p.Results.TargetPrice;
obj.stoplossprice_ = p.Results.StoplossPrice;
obj.riskmanagementmethod_ = p.Results.RiskManagementMethod;
obj.status_ = 'open';

end

