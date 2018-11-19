function tbl = displaypivottable(obj)
    tbl = {};
    if isempty(obj.options_), return; end
    if isempty(obj.pivottable_), obj.genpivottable; end

    fprintf('\t%s','ticker');
    fprintf('\t%8s','bid(c)');fprintf('%7s','ask(c)');fprintf('%8s','ivm(c)');
    fprintf('\t%s','strike');
    fprintf('\t%9s','ticker');
    fprintf('\t%8s','bid(p)');fprintf('%7s','ask(p)');fprintf('%8s','ivm(p)');
    fprintf('\t%8s','mid(u)');
    fprintf('\n');

    tbl = cell(size(obj.pivottable_,1),10);

    for i = 1:size(obj.pivottable_,1)
        strike = obj.pivottable_{i,2};
        c = obj.pivottable_{i,3};
        p = obj.pivottable_{i,4};

        idxc = 0;
        for j = 1:size(obj.quotes_,1)
            if strcmpi(c,obj.quotes_{j}.code_ctp),idxc = j;break; end
        end

        idxp = 0;
        for j = 1:size(obj.quotes_,1)
            if strcmpi(p,obj.quotes_{j}.code_ctp),idxp = j;break; end
        end

        if idxc ~= 0 
            ivc = obj.quotes_{idxc}.impvol;
            bc = obj.quotes_{idxc}.bid1;
            ac = obj.quotes_{idxc}.ask1;
            um = 0.5*(obj.quotes_{idxc}.bid_underlier + obj.quotes_{idxc}.ask_underlier);
        else
            ivc = NaN;
            bc = NaN;
            ac = NaN;
            um = NaN;
        end

        if idxp ~= 0    
            ivp = obj.quotes_{idxp}.impvol;
            bp = obj.quotes_{idxp}.bid1;
            ap = obj.quotes_{idxp}.ask1;
        else
            ivp = NaN;
            bp = NaN;
            ap = NaN;
        end

        tbl{i,1} = obj.pivottable_{i,3};
        tbl{i,2} = bc;
        tbl{i,3} = ac;
        tbl{i,4} = ivc;
        tbl{i,5} = strike;
        tbl{i,6} = obj.pivottable_{i,4};
        tbl{i,7} = bp;
        tbl{i,8} = ap;
        tbl{i,9} = ivp;
        tbl{i,10} = um;

        %add a blank line when underlying changed
        if i > 1 && ~strcmpi(obj.pivottable_{i,1},obj.pivottable_{i-1,1}) ,fprintf('\n'); end

        fprintf('%12s ', obj.pivottable_{i,3});
        fprintf('%6s ',num2str(bc));
        fprintf('%6s ',num2str(ac));
        fprintf('%6.1f%% ',ivc*100);
        fprintf('%6s ',num2str(strike));
        fprintf('%14s ', obj.pivottable_{i,4});
        fprintf('%6s ',num2str(bp));
        fprintf('%6s ',num2str(ap));
        fprintf('%6.1f%% ',ivp*100);
        fprintf('%9s ',num2str(um));
        fprintf('\n');

    end
    fprintf('\n');

end
%end of displaypivottable