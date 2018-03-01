function obj = init(obj)
    if ~isempty(obj.counterfut_),obj.counterfut_ = {};end
    obj.counterfut_ = CounterCTP.citic_kim_fut;
    %
    %
    if ~isempty(obj.counteropt1_), obj.counteropt1_ = {};end
    obj.counteropt1_ = CounterCTP.ccb_liyang_fut;
    %
    %
    if ~isempty(obj.counteropt2_), obj.counteropt2_ = {};end
    obj.counteropt2_ = CounterCTP.huaxin_liyang_fut;
    
    obj.qms_ = cQMS;
    obj.qms_.setdatasource('ctp');
    obj.mdefut_ = cMDEFut;
    obj.mdefut_.qms_ = obj.qms_;
    obj.mdeopt_ = cMDEOpt;
    obj.mdeopt_.qms_ = obj.qms_;

end