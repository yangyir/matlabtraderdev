function obj = init(obj,varargin)
p = inputParser;
p.CaseSensitive = false;
p.KeepUnmatched = true;
p.addParameter('ID',{},...
        @(x) validateattributes(x,{'char','numeric'},{},'','ID'));
p.addParameter('CounterName','',@ischar);
p.addParameter('BookName','',@ischar);
p.addParameter('Code','',@ischar);
p.addParameter('OpenDateTime',[],@isnumeric);
p.addParameter('OpenDirection',[],@isnumeric);
p.addParameter('OpenVolume',1,@isnumeric);
p.addParameter('OpenPrice',[],@isnumeric);
p.addParameter('StopDateTime',[],@isnumeric);
p.parse(varargin{:});
obj.id_ = p.Results.ID;
obj.countername_ = p.Results.CounterName;
obj.bookname_ = p.Results.BookName;
obj.code_ = p.Results.Code;
if ~isempty(obj.code_)
    instrument = code2instrument(obj.code_);
    obj.instrument_ = instrument;
end
obj.opendatetime1_ = p.Results.OpenDateTime;
if ~isempty(obj.opendatetime1_)
    obj.opendatetime2_ = datestr(obj.opendatetime1_,'yyyy-mm-dd HH:MM:SS');
end
obj.opendirection_ = p.Results.OpenDirection;
obj.openvolume_ = p.Results.OpenVolume;
obj.openprice_ = p.Results.OpenPrice;
obj.stopdatetime1_ = p.Results.StopDateTime;
if ~isempty(obj.stopdatetime1_)
    obj.stopdatetime2_ = datestr(obj.stopdatetime1_,'yyyy-mm-dd HH:MM:SS');
end
obj.status_ = 'unset';

end

