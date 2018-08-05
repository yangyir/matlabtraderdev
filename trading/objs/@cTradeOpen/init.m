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
p.addParameter('OpenVolume',[],@isnumeric);
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
direction = p.Results.OpenDirection;
if ~isempty(direction)
    if ~(direction == 1 || direction == -1), error('cTrade:invalid open direction');end
end
obj.opendirection_ = direction;
volume = p.Results.OpenVolume;
if ~isempty(volume)
    if volume <= 0, error('cTrade:invalid open volume');end
end
obj.openvolume_ = volume;
price = p.Results.OpenPrice;
if ~isempty(price)
    if price <= 0, error('cTrade:invalid open price');end
end
obj.openprice_ = price;
obj.stopdatetime1_ = p.Results.StopDateTime;
if ~isempty(obj.stopdatetime1_)
    obj.stopdatetime2_ = datestr(obj.stopdatetime1_,'yyyy-mm-dd HH:MM:SS');
end
obj.status_ = 'unset';

end

