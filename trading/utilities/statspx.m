function res = statspx(conn,codein)

    if ~isa(conn,'blp'),error('statspx:invalid bloomberg interface input');end
    
    if ~ischar(codein),error('statspx:invalid code input');end
    
    wr_params = 144;
    
    %%
    %5min 10-day
    enddate = getlastbusinessdate;
    freq = 5; 
    startdate_5m = enddate;
    count = 10;
    i = 1;
    while i < count
        startdate_5m = businessdate(startdate_5m,-1);
        i = i + 1;
    end
    data_5m = timeseries(conn,codein,{startdate_5m,businessdate(enddate,1)},freq,'trade');
    high_p_5m = data_5m(:,3);
    low_p_5m = data_5m(:,4);
    highest_p_5m = zeros(size(high_p_5m,1)-wr_params+1,1);
    lowest_p_5m = highest_p_5m;
    t_p_5m = highest_p_5m;
    for i = 1:size(highest_p_5m,1)
        t_p_5m(i) = data_5m(i+wr_params-1,1);
        highest_p_5m(i) = max(high_p_5m(i:i+wr_params-1));
        lowest_p_5m(i) = min(low_p_5m(i:i+wr_params-1));
    end
    %ploting
    figure(1)
    plot(highest_p_5m,'r');hold on;
    plot(lowest_p_5m,'g');
    plot(data_5m(wr_params:end,5),'b');hold off
    xgrid = get(gca,'XTick');
    xgrid = xgrid';
    idx = xgrid < size(highest_p_5m,1);
    xgrid = xgrid(idx,:);
    t_num = zeros(1,length(xgrid));
    for i = 1:length(t_num)
        if xgrid(i) == 0
            t_num(i) = t_p_5m(1,1);
        elseif xgrid(i) > size(highest_p_5m,1)
            t_start = t_num(1,1);
            t_last = t_num(end,1);
            t_num(i) = t_last + (xgrid(i)-size(t_num,1))*...
                (t_last - t_start)/size(t_num,1);
        else
            t_num(i) = t_p_5m(xgrid(i),1);
        end
    end

    t_str = datestr(t_num,'dd/mm');
    set(gca,'XTick',xgrid);
    set(gca,'XTickLabel',t_str);
    title('5-min moving high(red) and low(green) price');
    grid on;
    
    
    %statistics
    
    
    %%
    %15min 30-day
    startdate_15m = enddate;
    freq = 15;
    count = 30;
    i = 1;
    while i < count
        startdate_15m = businessdate(startdate_15m,-1);
        i = i + 1;
    end
    data_15m = timeseries(conn,codein,{startdate_15m,businessdate(enddate,1)},freq,'trade');
    high_p_15m = data_15m(:,3);
    low_p_15m = data_15m(:,4);
    highest_p_15m = zeros(size(high_p_15m,1)-wr_params+1,1);
    lowest_p_15m = highest_p_15m;
    for i = 1:size(highest_p_15m,1)
        highest_p_15m(i) = max(high_p_15m(i:i+wr_params-1));
        lowest_p_15m(i) = min(low_p_15m(i:i+wr_params-1));
    end
    figure(2)
    plot(highest_p_15m,'b')
    title('15-min moving high/low price');
    hold on;
    plot(lowest_p_15m,'r')
    legend('high','low');
    hold off;
    
    %%
    %30m 3-month
    startdate_30m = enddate;
    freq = 30;
    count = 60;
    i = 1;
    while i < count
        startdate_30m = businessdate(startdate_30m,-1);
        i = i + 1;
    end
    data_30m = timeseries(conn,codein,{startdate_30m,businessdate(enddate,1)},freq,'trade');
    high_p_30m = data_30m(:,3);
    low_p_30m = data_30m(:,4);
    highest_p_30m = zeros(size(high_p_30m,1)-wr_params+1,1);
    lowest_p_30m = highest_p_30m;
    for i = 1:size(highest_p_30m,1)
        highest_p_30m(i) = max(high_p_30m(i:i+wr_params-1));
        lowest_p_30m(i) = min(low_p_30m(i:i+wr_params-1));
    end
    figure(3)
    plot(highest_p_30m,'b')
    title('30-min moving high/low price');
    hold on;
    plot(lowest_p_30m,'r')
    legend('high','low');
    hold off;
    
    %%
    %60m 6-month
    startdate_60m = enddate;
    freq = 60;
    count = 120;
    i = 1;
    while i < count
        startdate_60m = businessdate(startdate_60m,-1);
        i = i + 1;
    end
    data_60m = timeseries(conn,codein,{startdate_60m,businessdate(enddate,1)},freq,'trade');
    high_p_60m = data_60m(:,3);
    low_p_60m = data_60m(:,4);
    highest_p_60m = zeros(size(high_p_60m,1)-wr_params+1,1);
    lowest_p_60m = highest_p_60m;
    for i = 1:size(highest_p_60m,1)
        highest_p_60m(i) = max(high_p_60m(i:i+wr_params-1));
        lowest_p_60m(i) = min(low_p_60m(i:i+wr_params-1));
    end
    figure(4)
    plot(highest_p_60m,'b')
    title('60-min moving high/low price');
    hold on;
    plot(lowest_p_60m,'r')
    legend('high','low');
    hold off;
end