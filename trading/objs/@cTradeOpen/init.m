function obj = init(obj,varargin)
p = inputParser;
p.CaseSensitive = false;
p.KeepUnmatched = true;
p.addParameter('ID',{},@(x) validateattributes(x,{'char','numeric'},{},'','ID'));
p.addParameter('BookName','',@ischar);
p.addParameter('TraderName','',@ischar);
p.addParameter('CounterName','',@ischar);
p.addParameter('Code','',@ischar);
p.addParameter('OpenDateTime',[],@isnumeric);
p.addParameter('OpenDirection',[],@isnumeric);
p.addParameter('OpenVolume',[],@isnumeric);
p.addParameter('OpenPrice',[],@isnumeric);
p.addParameter('StopDateTime',[],@isnumeric);
p.parse(varargin{:});
obj.id_ = p.Results.ID;
obj.bookname_ = p.Results.BookName;
obj.tradername_ = p.Results.TraderName;
obj.countername_ = p.Results.CounterName;
obj.code_ = p.Results.Code;
obj.opendatetime1_ = p.Results.OpenDateTime;
obj.opendirection_ = p.Results.OpenDirection;
obj.openvolume_ = p.Results.OpenVolume;
obj.openprice_ = p.Results.OpenPrice;
obj.stopdatetime1_ = p.Results.StopDateTime;
obj.status_ = 'unset';

if isempty(obj.instrument_)
    obj.oneminb4close1_ = 899;
    obj.oneminb4close2_ = NaN;
else
    if ~isempty(strfind(obj.instrument_.asset_name,'govtbond'))
        obj.oneminb4close1_ = 914;
        obj.oneminb4close2_ = NaN;
    elseif ~isempty(strfind(obj.instrument_.asset_name,'eqindex'))
        obj.oneminb4close1_ = 899;
        obj.oneminb4close2_ = NaN;
    elseif strcmpi(obj.instrument_.asset_name,'gold') ||...
            strcmpi(obj.instrument_.asset_name,'silver') ||...
            strcmpi(obj.instrument_.asset_name,'crude oil')
        obj.oneminb4close1_ = 899;
        obj.oneminb4close2_ = 149;
    elseif strcmpi(obj.instrument_.asset_name,'copper') ||...
            strcmpi(obj.instrument_.asset_name,'aluminum') ||...
            strcmpi(obj.instrument_.asset_name,'zinc') ||...
            strcmpi(obj.instrument_.asset_name,'lead') ||...
            strcmpi(obj.instrument_.asset_name,'nickel')
        obj.oneminb4close1_ = 899;
        obj.oneminb4close2_ = 59;
    else
        obj.oneminb4close1_ = 899;
        obj.oneminb4close2_ = 1379;
    end
end

end

