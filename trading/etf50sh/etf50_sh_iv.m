function [ iv_c,iv_p,marked_fwd,qo,qu ] = etf50_sh_iv( conn,opt_c,opt_p,exp_rt,k )
    code_bbg_underlier = '510050 CH Equity';
    sec_list = [code_bbg_underlier;opt_c;opt_p];
    d = conn.ds_.getdata(sec_list,{'bid';'ask'});
    
    nk = length(k);
    iv_c = zeros(nk,1);iv_p = iv_c;
    
    bid_u = d.bid(1);ask_u = d.ask(1);mid_u = 0.5*(bid_u+ask_u);
    bid_c = d.bid(2:nk+1);ask_c = d.ask(2:nk+1);mid_c = 0.5*(bid_c+ask_c);
    bid_p = d.bid(nk+2:end);ask_p = d.ask(nk+2:end);mid_p = 0.5*(bid_p+ask_p);
    
    % arb-monitor
    bid_fwd = k'+bid_c-ask_p;
    ask_fwd = k'+ask_c-bid_p;
    tau = (datenum(exp_rt,'yyyy-mm-dd')-today)/365;
    fprintf('\n%s(%sd)\n',exp_rt,num2str(tau*365));
    if max(bid_fwd) > min(ask_fwd)
        ishort = find(bid_fwd == max(bid_fwd),1,'first');
        ilong = find(ask_fwd == min(ask_fwd),1,'first');
        fprintf('box-arb exist:short synthetic fwd at strike %s and long at strike %s\n',...
            num2str(k(ishort)),num2str(k(ilong)));
    end
    
    marked_fwd = mean([bid_fwd;ask_fwd]);
    
    r = 0.025;
    for i = 1:nk
        iv_c(i) = blkimpv(marked_fwd,k(i),r,tau,mid_c(i),[],[],{'call'});
        iv_p(i) = blkimpv(marked_fwd,k(i),r,tau,mid_p(i),[],[],{'put'});
    end
    
    
    fprintf('%10s','bid(c)');fprintf('%10s','ask(c)');fprintf('%10s','ivm(c)');
    fprintf('%10s','strike');
    fprintf('%10s','bid(p)');fprintf('%10s','ask(p)');fprintf('%10s','ivm(p)');
    fprintf('%10s','mid(u)');
    fprintf('%10s','bid_fwd');
    fprintf('%10s','ask_fwd');
    fprintf('\n');
    for i = 1:nk
        fprintf('%10s',num2str(bid_c(i)));
        fprintf('%10s',num2str(ask_c(i)));
        fprintf('%9.1f%% ',iv_c(i)*100);
        fprintf('%9s ',num2str(k(i)));
        fprintf('%9s ',num2str(bid_p(i)));
        fprintf('%9s ',num2str(ask_p(i)));
        fprintf('%8.1f%% ',iv_p(i)*100);
        fprintf('%9s ',num2str(mid_u));
        fprintf('%9s ',num2str(bid_fwd(i)));
        fprintf('%9s ',num2str(ask_fwd(i)));
        fprintf('\n');
    end
    
    qo = [bid_c,ask_c,bid_p,ask_p];
    qu = [bid_u,ask_u];
    
    
    
    

end

