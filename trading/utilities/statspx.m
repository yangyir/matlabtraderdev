function res = statspx(conn,codein,interval)

    if ~isa(conn,'blp'),error('statspx:invalid bloomberg interface input');end
    
    if ~ischar(codein),error('statspx:invalid code input');end
    
    if nargin < 3
        interval = 5;
    end
        
    wr_params = 144;
    
    if interval == 5
        ndays = 15;
    elseif interval == 15
        ndays = 30;
    elseif interval == 30
        ndays = 90;
    elseif interval == 60
        ndays = 180;
    else
        error('invalid interval input')
    end
    
    %%
    enddate = getlastbusinessdate;
    startdate = enddate;
    i = 1;
    while i < ndays
        startdate = businessdate(startdate,-1);
        i = i + 1;
    end
    data = timeseries(conn,codein,{startdate,businessdate(enddate,1)},interval,'trade');
    hp = data(:,3);
    lp = data(:,4);
    cp = data(:,5);
    wpctr = willpctr(hp, lp, cp, wr_params);
    highestp = zeros(size(hp,1)-wr_params+1,1);
    lowestp = highestp;
    tp = data(wr_params:end,1);
    for i = 1:size(highestp,1)
        highestp(i) = max(hp(i:i+wr_params-1));
        lowestp(i) = min(lp(i:i+wr_params-1));
    end
    %%
    %ploting
    figure(1)
    subplot(211)
    plot(highestp,'r');hold on;
    plot(lowestp,'g');
    plot(cp(wr_params:end,1),'b');hold off
    xgrid = get(gca,'XTick');
    xgrid = xgrid';
    idx = xgrid < size(highestp,1);
    xgrid = xgrid(idx,:);
    t_num = zeros(1,length(xgrid));
    for i = 1:length(t_num)
        if xgrid(i) == 0
            t_num(i) = tp(1,1);
        elseif xgrid(i) > size(highestp,1)
            t_start = t_num(1,1);
            t_last = t_num(end,1);
            t_num(i) = t_last + (xgrid(i)-size(t_num,1))*...
                (t_last - t_start)/size(t_num,1);
        else
            t_num(i) = tp(xgrid(i),1);
        end
    end

    t_str = datestr(t_num,'dd/mm');
    set(gca,'XTick',xgrid);
    set(gca,'XTickLabel',t_str);
    title([num2str(interval),'-min moving high(red) and low(green) price']);
    grid on;
    
    subplot(212)
    plot(wpctr(wr_params:end),'Color',[.75,.75,.75]);
    set(gca,'XTick',xgrid);
    set(gca,'XTickLabel',t_str);
    grid on;
    title(['wlpr(144):  ',num2str(wpctr(end))]);
    
    
    %%
    %statistics
    cp_last = cp(end);
    highestp_last = highestp(end);
    lowestp_last = lowestp(end);
    highestp_unique = unique(highestp);
    lowestp_unique = unique(lowestp);
    highestp_quantile = (size(highestp_unique,1) - find(highestp_unique==highestp_last))/size(highestp_unique,1);
    lowestp_quantile = find(lowestp_unique==lowestp_last)/size(highestp_unique,1);
    
    res = struct('px_last',cp_last,...
        'wr_last',wpctr(end),...
        'highest_last',highestp_last,...
        'lowest_last',lowestp_last,...
        'highest_quantile',highestp_quantile,...
        'lowestp_quantile',lowestp_quantile,...
        'highest',{highestp_unique},...
        'lowest',{lowestp_unique});
    
    

end