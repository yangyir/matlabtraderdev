function [] = refresh(obj,qms)
    qms.refresh;
    opts = obj.options_.getinstrument;
    n = obj.options_.count;
    obj.ivs_ = zeros(n,1);
    for i = 1:n
        q = qms.getquote(opts{i});
        obj.ivs_(i,1) = q.impvol;
        obj.update_date1_ = q.update_date1;
        obj.update_date2_ = q.update_date2;
        obj.update_time1_ = q.update_time1;
        obj.update_time2_ = q.update_time2;
        obj.calendar_tau_ = q.opt_calendar_tau;
        obj.business_tau_ = q.opt_business_tau;
        obj.underlier_spot_ = q.last_trade_underlier;
    end
    
    
end