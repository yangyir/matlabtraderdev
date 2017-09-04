function output = govtbond_trading_highfreq(rollinfo10y)

rollInfoTbl = rollinfo10y.RollInfo;
firstbd = rollinfo10y.ContinousFutures(1,1);
lastbd = rollinfo10y.ContinousFutures(end,1);

tbl = cell(size(rollInfoTbl,1)+1,4);
tbl(1:end-1,1) = rollInfoTbl(1:end,4);
tbl(end,1) = rollInfoTbl(end,5);

%always take the same tenor 5y bond futures for the 5-10y yield curve
%calculation
for i = 1:size(tbl,1)
    tbl{i,2} = ['TF',tbl{i,1}(2:end)];
    if i == 1
        tbl{i,3} = firstbd;
        tbl{i,4} = rollInfoTbl{1,1};
    elseif i == size(tbl,1)
        tbl{i,3} = rollInfoTbl{i-1,1};
        tbl{i,4} = lastbd;
    else
        tbl{i,3} = rollInfoTbl{i-1,1};
        tbl{i,4} = rollInfoTbl{i,1};
    end
end

output = cell(size(tbl,1),1);

%
%try to initiate/update the 1min intraday data
for i = 1:size(tbl,1)
    contract10y = windcode2contract(tbl{i,1}(1:length(tbl{i,1})-4));
    contract5y = windcode2contract(tbl{i,2}(1:length(tbl{i,2})-4));
    
    expiry = contract10y.Expiry;
        
    if expiry < lastbd
        status = 'dead';
    else
        status = 'live';
    end
    
    try
        tsobj = contract10y.getTimeSeriesObj('Connection','Bloomberg',...
            'Frequency','1m');
        lastentry = datenum(tsobj.getLastDateEntry);
        %note:for the live contract we will update the timeseries in case
        %it is needed. 
        if strcmpi(status,'live') && lastentry < lastbd
            contract10y.updateTimeSeries('Connection','Bloomberg',...
                'Frequency','1m');
            %
            contract5y.updateTimeSeries('Connection','Bloomberg',...
                'Frequency','1m');
        %However,we will always update the timeseries of an
        %expired contract in case the dataset is not complete for various
        %reasons
        elseif strcmpi(status,'dead') && lastentry < expiry
            contract10y.updateTimeSeries('Connection','Bloomberg',...
                'Frequency','1m');
            %
            contract5y.updateTimeSeries('Connection','Bloomberg',...
                'Frequency','1m');
        end
    catch
        %note:in case the timeseries object cannot be found via calling the
        %'getTimeSeriesObj' method of a cContract object, it indicates that
        %the timeseries is not initialized yet and thus 'initTimeSeries'
        %method of a cContract object needs to be called
        contract10y.initTimeSeries('Connection','Bloomberg',...
            'Frequency','1m',...
            'DataSource','internet');
        %
        contract5y.initTimeSeries('Connection','Bloomberg',...
            'Frequency','1m',...
            'DataSource','internet');
    end
    %
    %
    %try to compute the yld using the downloaded price
    tsobj10y = contract10y.getTimeSeriesObj('Connection','Bloomberg',...
            'Frequency','1m');
    tsobj5y = contract5y.getTimeSeriesObj('Connection','Bloomberg',...
            'Frequency','1m');    
    if ~isempty(tsobj10y.Frequency) && ~isempty(tsobj5y.Frequency)
        data10y = contract10y.getTimeSeries('Connection','Bloomberg',...
            'Fields',{'close'}, 'frequency','1m',...
            'FromDate',[datestr(tbl{i,3}),' 09:15:00'],...
            'ToDate',[datestr(tbl{i,4}),' 15:15:00']);
        data5y = contract5y.getTimeSeries('Connection','Bloomberg',...
            'Fields',{'close'}, 'frequency','1m',...
            'FromDate',[datestr(tbl{i,3}),' 09:15:00'],...
            'ToDate',[datestr(tbl{i,4}),' 15:15:00']);
        [t,idx1,idx2] = intersect(data5y(:,1),data10y(:,1));
        if ~isempty(t)
            d = floor(t);
            dtbl = zeros(size(t,1),6);
            dtbl(:,1) = t;
            dtbl(:,2) = data5y(idx1,2);
            dtbl(:,3) = data10y(idx2,2);
            dtbl(:,4) = bndyield(dtbl(:,2),0.03,d,dateadd(d,'5y'));
            dtbl(:,5) = bndyield(dtbl(:,3),0.03,d,dateadd(d,'10y'));
            dtbl(:,6) = (dtbl(:,5)-dtbl(:,4))*10000;
            %
            output{i} = struct('Tenor',contract10y.Tenor,...
                'Data',dtbl);
        end

    end
    
end



end