function callback_bbg_510050CH_vanilla(obj,event,c,tenor)
%callback function to retrieve option quotes from bloomberg

if isempty(obj.UserData)
    %first time to run the callback function after initialization
    %the latest daily price return
    underlier = '510050 CH Equity';
    data = getdata(c,underlier,'last_close_trr_1d');
    dailyReturn = data.last_close_trr_1d/100;
    data = getdata(c,underlier,'px_close');
    closePrice = data.px_close;
    data = getdata(c,underlier,'px_close_dt');
    closeDate = data.px_close_dt;
    
    userData = struct('Underlier',underlier,...
        'LastCloseDate',closeDate,...
        'LastClosePrice',closePrice,...
        'LastDailyReturn',dailyReturn);
    obj.UserData = userData;    
end

ud = obj.UserData;

%---option quotoes and valuation
fprintf([datestr(event.Data.time),' timer runs....\n']);
output = listedoptinfo(c,'50etf',tenor,'PrintOutput',true);
userData = struct('Underlier',ud.Underlier,...
        'LastCloseDate',ud.LastCloseDate,...
        'LastClosePrice',ud.LastClosePrice,...
        'LastDailyReturn',ud.LastDailyReturn,...
        'Output',output);

obj.UserData = userData;

end