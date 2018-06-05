function obj = init(obj,varargin)
p = inputParser;
p.CaseSensitive = false;
p.KeepUnmatched = true;
p.addParameter('ID',{},...
        @(x) validateattributes(x,{'char','numeric'},{},'','ID'));
p.addParameter('CounterName','',@ischar);
p.addParameter('CTPCode','',@ischar);
p.addParameter('OpenTime',[],@isnumeric);
p.addParameter('OpenDirection',[],@isnumeric);
p.addParameter('OpenPrice',[],@isnumeric);
p.addParameter('TargetPrice',[],@isnumeric);
p.addParameter('StoplossPrice',[],@isnumeric);
p.addParameter('StopTime',[],@isnumeric);
p.addParameter('RiskManagementMethod','standard',@ischar);
p.parse(varargin{:});
obj.id_ = p.Results.ID;
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
obj.stoptime1_ = p.Results.StopTime;
if ~isempty(obj.stoptime1_)
    obj.stoptime2_ = datestr(obj.stoptime1_,'yyyy-mm-dd HH:MM:SS');
end
obj.riskmanagementmethod_ = p.Results.RiskManagementMethod;
obj.status_ = 'unset';

batman = cBatman;
batman.code_ = obj.ctpcode_;
batman.direction_ = obj.opendirection_;
batman.pxopen_ = obj.openprice_;
batman.pxopenreal_ = obj.openprice_;
batman.pxtarget_ = obj.targetprice_;
batman.pxstoploss_ = obj.stoplossprice_;
batman.dtunwind1_ = obj.stoptime1_;
batman.dtunwind2_ = obj.stoptime2_;
obj.batman_ = batman;
end

