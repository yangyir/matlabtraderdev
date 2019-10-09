function obj = init(obj,varargin)
%bkcStraddle
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('id',[],@isnumeric);
    p.addParameter('code','',@ischar);
    p.addParameter('strike',[],@isnumeric);
    p.addParameter('opendt',[],@isnumeric);
    p.addParameter('expirydt',[],@isnumeric);
    p.parse(varargin{:});
    obj.id_ = p.Results.id;
    obj.code_ = p.Results.code;
    obj.strike_ = p.Results.strike;
    obj.opendt1_ = p.Results.opendt;
    obj.expirydt1_ = p.Results.expirydt;
    if isempty(obj.opendt1_) || isempty(obj.expirydt1_)
        obj.tradedts_ = [];
        obj.pvs_ = [];
        obj.deltas_ = [];
        obj.S_ = [];
        obj.thetapnl_ = [];
        obj.deltapnl_ = [];
        obj.status_ = [];
    else
        obj.tradedts_ = gendates('fromdate',obj.opendt1_,'todate',obj.expirydt1_);
        obj.pvs_ = zeros(length(obj.tradedts_),1);
        obj.deltas_ = obj.pvs_;
        obj.S_ = obj.pvs_;
        obj.thetapnl_ = obj.pvs_;
        obj.deltapnl_ = obj.pvs_;
        obj.status_ = ones(length(obj.tradedts_),1);obj.status_(end) = 0;
    end
end