function tbl = genpivottable(obj)
    underliers = obj.underliers_.getinstrument;
    options = obj.options_.getinstrument;

    nu = size(underliers,1);
    no = size(options,1);
    if mod(no,2) ~= 0, error('cMDEOpt:pivottable:number of options shall be even'); end

    tbl = cell(no/2,4);

    count = 0;
    for i = 1:nu
        u = underliers{i};
        for j = 1:no
            o = options{j};
            u_ = o.code_ctp_underlier;
            if ~strcmpi(u.code_ctp,u_), continue; end
            if i == 1 && j == 1
                count = count + 1;
                tbl{count,1} = u.code_ctp;
                tbl{count,2} = o.opt_strike;
                if strcmpi(o.opt_type,'C'),tbl{count,3} = o.code_ctp;else tbl{count,4} = o.code_ctp;end
            else
                strike = o.opt_strike;
                flag = false;
                for k = 1:count
                        if strcmpi(tbl{k,1},u_) && tbl{k,2} == strike
                            flag = true;
                            if strcmpi(o.opt_type,'C'),tbl{k,3} = o.code_ctp;else tbl{k,4} = o.code_ctp;end
                            break
                        end

                end
                if ~flag
                    count = count + 1;
                    tbl{count,1} = u_;
                    tbl{count,2} = strike;
                    if strcmpi(o.opt_type,'C'), tbl{count,3} = o.code_ctp;else tbl{count,4} = o.code_ctp;end
                end
            end  
        end 
    end

    obj.pivottable_ = tbl;
end
%end of genpivottable