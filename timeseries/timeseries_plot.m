function results = timeseries_plot(data,varargin)
% this function, as its name implies, does timeseries plot
% results = timeseries_plot(data)
% results = timeseries_plot(data,param1,paravalue1,...,paramN,paravalueN)
% param can be 'FromDate','ToDate','DateFormat','DateLabel';
% syntax: 
% results = timeseries_plot(data,'FromDate',date)
% results = timeseries_plot(data,'ToDate',date)
% results = timeseries_plot(data,'FromDate',date1,'ToDate',date2)
% results = timeseries_plot(data,'FromDate',date1,'ToDate',date2,...
%                                   'DateFormat','dd-mmm-yyyy')


% default values
datenum_from = NaN;
datenum_to = NaN;
date_format = [];
date_label = [];
title_label = [];

if nargin == 1
    results = data;
else
    for i = 1:length(varargin)
        if strcmpi(varargin{i},'FromDate')
            datenum_from = datenum(varargin{i+1});
        elseif strcmpi(varargin{i},'ToDate')
            datenum_to = datenum(varargin{i+1});
        elseif strcmpi(varargin{i},'DateFormat')
            date_format = varargin{i+1};
        elseif strcmpi(varargin{i},'DateLabel')
            date_label = varargin{i+1};
        elseif strcmpi(varargin{i},'Title')
            title_label = varargin{i+1};
        end
    end
    %
    if isnan(datenum_from) && isnan(datenum_to)
        results = data;
    end
    %
    if ~isnan(datenum_from) && isnan(datenum_to)
       results = timeseries_window(data,'FromDate',datestr(datenum_from));
    end
    %
    if isnan(datenum_from) && ~isnan(datenum_to)
       results = timeseries_window(data,'ToDate',datestr(datenum_to));
    end
    %
    if ~isnan(datenum_from) && ~isnan(datenum_to)
       results = timeseries_window(data,'FromDate',datestr(datenum_from),...
                                    'ToDate',datestr(datenum_to));
    end
        
end

figure;
plot(results(:,2),'b');

if isempty(date_label)
    xgrid = get(gca,'XTick');
    xgrid = xgrid';
    idx = xgrid < size(results,1);
    xgrid = xgrid(idx,:);
    t_num = zeros(1,length(xgrid));
    for i = 1:length(t_num)
        if xgrid(i) == 0
            t_num(i) = results(1,1);
        elseif xgrid(i) > size(results,1)
            t_start = results(1,1);
            t_last = results(end,1);
            t_num(i) = t_last + (xgrid(i)-size(results,1))*...
                (t_last - t_start)/size(results,1);
        else
            t_num(i) = results(xgrid(i),1);
        end
    end
    if isempty(date_format)
        t_str = datestr(t_num);
    else
        t_str = datestr(t_num,date_format);
    end
    set(gca,'XTick',xgrid);
    set(gca,'XTickLabel',t_str);
else
    t_str = cell(1,length(date_label)+1);
    xgrid = zeros(1,length(date_label)+1);
    t_str{1} = datestr(results(1,1),'dd-mmm-yyyy');
    tnum_last = results(end,1);
    for i = 2:length(xgrid)
       date_i = datestr(date_label{i-1},'dd-mmm-yyyy');
       t_num_i = datenum([date_i,' 23:59:59'],'dd-mmm-yyyy HH:MM:SS');
       if t_num_i <= tnum_last
           idx = find(results(:,1)<= t_num_i);
       else
           idx = [];
       end
       if isempty(idx)
           xgrid(i) = NaN;
       elseif ismember(idx(end),xgrid)
           xgrid(i) = NaN;
       else
           xgrid(i) = idx(end);
           t_str{i} = date_label{i-1};
       end
    end
    % remove NaN and empty cells
    idx = ~isnan(xgrid);
    xgrid = xgrid(:,idx);
    t_str = t_str(:,idx);
    if ~isempty(date_format)
        t_str = datestr(t_str,date_format);
    end
    % set values
    set(gca,'XTick',xgrid);
    set(gca,'XTickLabel',t_str);
end

xlabel('Date');
if ~isempty(title_label)
    title(title_label)
end
grid on;

end