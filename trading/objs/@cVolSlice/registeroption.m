function [] = registeroption(obj,opt)
    if ischar(opt)
        [isopt,opt_type,opt_strike,underlierstr,opt_expiry]  = isoptchar(opt);
        if ~isopt
            error('cVolSlice:registeroption:invalid opt input')
        end
        
    elseif isa(opt,'cOption')
        opt_type = opt.opt_type;
        opt_strike = opt.opt_strike;
        underlierstr = opt.code_ctp_underlier;
        opt_expiry = opt.opt_expiry_date1;
    end
        
    if isempty(obj.type_)
        obj.type_ = opt_type;
    else
        if ~strcmpi(obj.type_,opt_type)
            error('cVolSlice:registeroption:input option has a different type from the volslice')
        end
    end

    if isempty(obj.expiry1_)
        obj.expiry1_ = opt_expiry;
        obj.expiry2_ = datestr(obj.expiry1_,'yyyy-mm-dd');
    else
        if obj.expiry1_ ~= opt_expiry
            error('cVolSlice:registeroption:input option has a different expiry from the volslice')
        end
    end

    if isempty(obj.underlier_)
        obj.underlier_ = cFutures(underlierstr);
        obj.underlier_.loadinfo([underlierstr,'_info.txt']);
    else
        if ~strcmpi(underlierstr,obj.underlier_.code_ctp)
            error('cVolSlice:registeroption:input option has a different underlier from the volslice')
        end
    end

    if isempty(obj.strikes_)
        obj.strikes_ = opt_strike;
    else
        strikes = [obj.strikes_;opt_strike];
        strikes = unique(strikes);
        strikes = sort(strikes);
        obj.strikes_ = strikes;
    end
    
    if ischar(opt)
        optobj = cOption(opt);
        optobj.loadinfo([opt,'_info.txt']);
    else
        optobj = opt;
    end
    
    if isempty(obj.options_)
        obj.options_ = cInstrumentArray;
    end
    obj.options_.addinstrument(optobj);
            
       
end