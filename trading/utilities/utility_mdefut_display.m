function [] = utility_mdefut_display( mdefut,code )
    K = mdefut.getallcandles(code);
    p = K{1};
    fprintf('\n%6s:last k time:%s\tprice:%s\n',code,datestr(p(end,1),'yy-mm-dd HH:MM'),num2str(p(end,5)));
    [bs,ss,lvlup,lvldn,bc,sc] = tdsq(p);
    [macdvec,nineperma] = macd(p(:,5));
    diffvec = macdvec - nineperma;
    np = size(p,1);
    refs_intraday = tdsq_plotopensignal(np,p,bs,ss,lvlup,lvldn,bc,sc,diffvec,1);
    if ~isempty(refs_intraday.k4)
        lb = refs_intraday.y4+refs_intraday.k4*refs_intraday.x(end);
        ub = refs_intraday.y3+refs_intraday.k3*refs_intraday.x(end);
    else
        lb = refs_intraday.y2+refs_intraday.k2*refs_intraday.x(end);
        ub = refs_intraday.y1+refs_intraday.k1*refs_intraday.x(end);
    end
    fprintf('lb:%s\tup:%s\n',num2str(lb),num2str(ub));
    %
    K_today = mdefut.getcandles(code);
    
    hd = cDataFileIO.loadDataFromTxtFile([code,'_daily.txt']);hd = hd(:,1:5);
    if isempty(K_today)
        p_daily = hd;
    else
        K_today = K_today{1};
        d_rt = [today,K_today(1,2),max(K_today(:,3)),min(K_today(:,4)),K_today(end,5)];
        p_daily = [hd;d_rt];
    end
    
    [bs_daily,ss_daily,lvlup_daily,lvldn_daily,bc_daily,sc_daily] = tdsq(p_daily);
    [macdvec_daily,nineperma_daily] = macd(p_daily(:,5));
    diffvec_daily = macdvec_daily-nineperma_daily;
    dailyrefs = macdenhanced(size(p_daily,1),p_daily(:,1:5),diffvec_daily);
    fprintf('\ndaily info:%s\n',code);
    fprintf('%8s\t%8s\t%8s\t%8s\t%8s\t%8s\t%8s\t%8s\t%8s\n','date','open','high','low','last','lvlup','lvldn','lb','ub')
    fprintf('%8s\t',datestr(p_daily(end,1),'yy-mm-dd'));
    fprintf('%8s\t',num2str(p_daily(end,2)));
    fprintf('%8s\t',num2str(p_daily(end,3)));
    fprintf('%8s\t',num2str(p_daily(end,4)));
    fprintf('%8s\t',num2str(p_daily(end,5)));
    fprintf('%8s\t',num2str(lvlup_daily(end)));
    fprintf('%8s\t',num2str(lvldn_daily(end)));
    fprintf('%8.1f\t',dailyrefs.lbrunning);
    fprintf('%8.1f\t',dailyrefs.ubrunning);
    fprintf('\n');
    tdsq_plotopensignal(size(p_daily,1),p_daily(:,1:5),bs_daily,ss_daily,lvlup_daily,lvldn_daily,bc_daily,sc_daily,diffvec_daily,2);
    %
    tdsq_plot2(p_daily(:,1:5),size(p_daily,1)-126,size(p_daily,1),code2instrument(code),3);
end

