function tbl = displaypivottable(mdeopt)
    tbl = {};
    if isempty(mdeopt.options_), return; end
    

    if isempty(mdeopt.pivottable_), mdeopt.genpivottable; end
    
    fprintf('\n');
    fprintf('%14s','ticker');
    fprintf('\t%6s','bid(c)');fprintf('\t%6s','ask(c)');fprintf('\t%6s','ivm(c)');fprintf('\t%6s','d(c)');
    fprintf('\t%6s','strike');
    fprintf('\t%14s','ticker');
    fprintf('\t%6s','bid(p)');fprintf('\t%6s','ask(p)');fprintf('\t%6s','ivm(p)');fprintf('\t%6s','d(p)');
    fprintf('\t%6s','mid(u)');
    fprintf('\t%9s','time');
    fprintf('\n');

    tbl = cell(size(mdeopt.pivottable_,1),12);

    for i = 1:size(mdeopt.pivottable_,1)
        strike = mdeopt.pivottable_{i,2};
        c = mdeopt.pivottable_{i,3};
        p = mdeopt.pivottable_{i,4};

        idxc = 0;
        for j = 1:size(mdeopt.quotes_,1)
            if strcmpi(c,mdeopt.quotes_{j}.code_ctp),idxc = j;break; end
        end

        idxp = 0;
        for j = 1:size(mdeopt.quotes_,1)
            if strcmpi(p,mdeopt.quotes_{j}.code_ctp),idxp = j;break; end
        end

        if idxc ~= 0 
            ivc = mdeopt.quotes_{idxc}.impvol;
            bc = mdeopt.quotes_{idxc}.bid1;
            ac = mdeopt.quotes_{idxc}.ask1;
            um = 0.5*(mdeopt.quotes_{idxc}.bid_underlier + mdeopt.quotes_{idxc}.ask_underlier);
            deltac = mdeopt.quotes_{idxc}.delta;
        else
            ivc = NaN;
            bc = NaN;
            ac = NaN;
            um = NaN;
            deltac = NaN;
        end

        if idxp ~= 0    
            ivp = mdeopt.quotes_{idxp}.impvol;
            bp = mdeopt.quotes_{idxp}.bid1;
            ap = mdeopt.quotes_{idxp}.ask1;
            deltap = mdeopt.quotes_{idxp}.delta;
        else
            ivp = NaN;
            bp = NaN;
            ap = NaN;
            deltap = NaN;
        end

        tbl{i,1} = mdeopt.pivottable_{i,3};
        tbl{i,2} = bc;
        tbl{i,3} = ac;
        tbl{i,4} = ivc;
        tbl{i,5} = deltac;
        tbl{i,6} = strike;
        tbl{i,7} = mdeopt.pivottable_{i,4};
        tbl{i,8} = bp;
        tbl{i,9} = ap;
        tbl{i,10} = ivp;
        tbl{i,11} = deltap;
        tbl{i,12} = um;

        %add a blank line when underlying changed
        if i > 1 && ~strcmpi(mdeopt.pivottable_{i,1},mdeopt.pivottable_{i-1,1}) ,fprintf('\n'); end

        fprintf('%14s ', mdeopt.pivottable_{i,3});
        fprintf('\t%6s ',num2str(bc));
        fprintf('\t%6s ',num2str(ac));
        fprintf('\t%5.1f%% ',ivc*100);
        fprintf('\t%5.1f%% ',deltac*100);
        fprintf('\t%6s ',num2str(strike));
        fprintf('\t%14s ', mdeopt.pivottable_{i,4});
        fprintf('\t%6s ',num2str(bp));
        fprintf('\t%6s ',num2str(ap));
        fprintf('\t%5.1f%% ',ivp*100);
        fprintf('\t%5.1f%% ',deltap*100);
        fprintf('\t%6s ',num2str(um));
        if strcmpi(mdeopt.mode_,'replay')
            fprintf('\t%9s',datestr(mdeopt.replay_time1_,'HH:MM:SS'));
        else
            fprintf('\t%9s',datestr(now,'HH:MM:SS'));
        end
        fprintf('\n');

    end
    fprintf('\n');

end
%end of displaypivottable