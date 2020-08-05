function [output] = opt_settle_riskpnl(conn,underlier,strikes,datein)
    if nargin < 4
        datein = getlastbusinessdate;
    end
    
    date1 = businessdate(datein,-1);
    date1str = datestr(date1,'yyyy-mm-dd');
    date2str = datestr(datein,'yyyy-mm-dd');
    
    fut = code2instrument(underlier);
    nk = length(strikes);
    opt_c = cell(nk,1);opt_p = opt_c;
    for i = 1:nk
        opt_c{i} = code2instrument([underlier,'-C-',num2str(strikes(i))]);
        opt_p{i} = code2instrument([underlier,'-P-',num2str(strikes(i))]);
    end
    
    fut_settle = conn.ds_.history(fut.code_bbg,'px_settle',date1str,date2str);

    opt_c_settle = zeros(2,length(strikes));
    opt_p_settle = zeros(2,length(strikes));

    for i = 1:nk
        d = conn.ds_.history(opt_c{i}.code_bbg,'px_settle',date1str,date2str);
        opt_c_settle(:,i) = d(:,2);
        %
        d = conn.ds_.history(opt_p{i}.code_bbg,'px_settle',date1str,date2str);
        opt_p_settle(:,i) = d(:,2);
    end
    
    iv_settle = zeros(2,length(strikes));
    fwd_settle = opt_c_settle-opt_p_settle;
    for i = 1:2
        fwd_settle(i,:) = fwd_settle(i,:)+strikes;
    end
    
    for i = 1:2
        for j = 1:nk
            if strikes(j) < fwd_settle(i,j)
                iv_settle(i,j) = bjsimpv(fwd_settle(i,j),strikes(j),0,fut_settle(i,1),opt_c{j}.opt_expiry_date1,opt_p_settle(i,j),[],0,[],'put');
            else
                iv_settle(i,j) = bjsimpv(fwd_settle(i,j),strikes(j),0,fut_settle(i,1),opt_p{j}.opt_expiry_date1,opt_c_settle(i,j),[],0,[],'call');
            end
        end
    end
    
    %pnl attribution
    pnl_c_theta = zeros(1,nk);pnl_p_theta = zeros(1,nk);
    pnl_c_delta = zeros(1,nk);pnl_p_delta = zeros(1,nk);
    pnl_c_gamma = zeros(1,nk);pnl_p_gamma = zeros(1,nk);
    pnl_c_vega = zeros(1,nk);pnl_p_vega = zeros(1,nk);
    pnl_c_other = zeros(1,nk);pnl_p_other = zeros(1,nk);
    
    for i = 1:nk
        info_c = opt_reval(opt_c{i},date1,fwd_settle(1,i),iv_settle(1,i));
        pnl_c_theta(i) = info_c.theta;
        pnl_c_delta(i) = info_c.delta*(fwd_settle(2,1)/fwd_settle(1,1)-1);
        pnl_c_gamma(i) = 0.5*info_c.gamma*(fwd_settle(2,1)/fwd_settle(1,1)-1)^2*100;
        pnl_c_vega(i) = info_c.vega*(iv_settle(2,i)-iv_settle(1,i))*100;
        pnl_c_other(i) = (opt_c_settle(2,i)-opt_c_settle(1,i))*opt_c{i}.contract_size  -...
            (pnl_c_theta(i)+pnl_c_delta(i)+pnl_c_gamma(i)+pnl_c_vega(i));
        %
        info_p = opt_reval( opt_p{i},date1,fwd_settle(1,i),iv_settle(1,i));
        pnl_p_theta(i) = info_p.theta;
        pnl_p_delta(i) = info_p.delta*(fwd_settle(2,1)/fwd_settle(1,1)-1);
        pnl_p_gamma(i) = 0.5*info_p.gamma*(fwd_settle(2,1)/fwd_settle(1,1)-1)^2*100;
        pnl_p_vega(i) = info_p.vega*(iv_settle(2,i)-iv_settle(1,i))*100;
        pnl_p_other(i) = (opt_p_settle(2,i)-opt_p_settle(1,i))*opt_p{i}.contract_size-...
            (pnl_p_theta(i)+pnl_p_delta(i)+pnl_p_gamma(i)+pnl_p_vega(i));
    end
    
    %risk attribution
    c_theta = zeros(1,nk);p_theta = zeros(1,nk);
    c_delta = zeros(1,nk);p_delta = zeros(1,nk);
    c_gamma = zeros(1,nk);p_gamma = zeros(1,nk);
    c_vega = zeros(1,nk);p_vega = zeros(1,nk);
    for i = 1:nk
        info_c_carry = opt_reval(opt_c{i},datein, fwd_settle(2,i),iv_settle(2,i));
        c_theta(i) = info_c_carry.theta;
        c_delta(i) = info_c_carry.delta;
        c_gamma(i) = info_c_carry.gamma;
        c_vega(i) = info_c_carry.vega;
        %
        info_p_carry = opt_reval(opt_p{i},datein, fwd_settle(2,i),iv_settle(2,i));
        p_theta(i) = info_p_carry.theta;
        p_delta(i) = info_p_carry.delta;
        p_gamma(i) = info_p_carry.gamma;
        p_vega(i) = info_p_carry.vega;
    end
    
    output = struct('fut_settle',fut_settle,...
        'opt_c_settle',opt_c_settle,...
        'opt_p_settle',opt_p_settle,...
        'iv_settle',iv_settle,...
        'pnl_c_theta',pnl_c_theta,...
        'pnl_c_delta',pnl_c_delta,...
        'pnl_c_gamma',pnl_c_gamma,...
        'pnl_c_vega',pnl_c_vega,...
        'pnl_c_other',pnl_c_other,...
        'pnl_p_theta',pnl_p_theta,...
        'pnl_p_delta',pnl_p_delta,...
        'pnl_p_gamma',pnl_p_gamma,...
        'pnl_p_vega',pnl_p_vega,...
        'pnl_p_other',pnl_p_other,...
        'c_theta',c_theta,...
        'c_delta',c_delta,...
        'c_gamma',c_gamma,...
        'c_vega',c_vega,...
        'p_theta',p_theta,...
        'p_delta',p_delta,...
        'p_gamma',p_gamma,...
        'p_vega',p_vega);
    
    
        
end