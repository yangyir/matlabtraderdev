function [] = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_)
%cQuoteFut
    if ~obj.init_flag
        obj.init(codestr);
    end

    if isnumeric(date_)
        obj.update_date1 = date_;
        obj.update_date2 = datestr(date_,'yyyy-mm-dd');
    else
        obj.update_date1 = datenum(date_);
        obj.update_date2 = datestr(date_,'yyyy-mm-dd');
    end

    if iscell(time_), time_ = time_{1};end

    if ischar(time_)
        %note:a bit hard-coded here
        dstr = [obj.update_date2,' ',time_];
        obj.update_time2 = dstr; 
        obj.update_time1 = datenum(dstr,'yyyy-mm-dd HH:MM:SS'); 
    elseif isnumeric(time_)
        obj.update_time1 = time_;
        obj.update_time2 = datestr(time_,'yyyy-mm-dd HH:MM:SS');
    else
        obj.update_time1 = NaN;
        obj.update_time2 = '';
    end

    obj.last_trade = trade_;
    obj.bid1 = bid_;
    obj.ask1 = ask_;
    obj.bid_size1 = bidsize_;
    obj.ask_size1 = asksize_;

    if strcmpi(obj.code_bbg(1:3),'TFT') && isempty(strfind(obj.code_bbg,','))
        obj.bond_flag = true;
        obj.bond_tenor = '10y';
    elseif strcmpi(obj.code_bbg(1:3),'TFC') && isempty(strfind(obj.code_bbg,','))
        obj.bond_flag = true;
        obj.bond_tenor = '5y';
    end

    if obj.bond_flag
        warning('off','finance:bndyield:solutionConvergenceFailure');
        if ~(isnan(obj.last_trade) || isnan(obj.bid1) || isnan(obj.ask1))
            ylds = bndyield([obj.last_trade,obj.bid1,obj.ask1],0.03,...
                obj.update_date1,dateadd(obj.update_date1,obj.bond_tenor));
            obj.yield_last_trade = ylds(1)*1e2;
            obj.yield_bid1 = ylds(2)*1e2;
            obj.yield_ask1 = ylds(3)*1e2;

            obj.duration = bnddurp(obj.last_trade,0.03,obj.update_date1,...
                dateadd(obj.update_date1,obj.bond_tenor));
        else
            obj.yield_last_trade = NaN;
            obj.yield_bid1 = NaN;
            obj.yield_ask1 = NaN;
            obj.duration = NaN;
        end
    end

end