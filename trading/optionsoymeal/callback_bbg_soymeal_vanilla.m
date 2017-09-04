function callback_bbg_soymeal_vanilla(obj,event,c,tenor)
%callback function to retrieve option quotes from bloomberg

if isempty(obj.UserData)
    %first time to run the callback function after initialization
    %the latest daily price return
    underlier = 'AEU7 Comdty';
    data = getdata(c,underlier,'px_yest_close');
    closePrice = data.px_yest_close/100;
    data = getdata(c,underlier,'px_close_dt');
    closeDate = data.px_close_dt;
    
    userData = struct('Underlier',underlier,...
        'LastCloseDate',closeDate,...
        'LastClosePrice',closePrice);
    obj.UserData = userData;    
end

ud = obj.UserData;

%---option quotoes and valuation
fprintf([datestr(event.Data.time),' timer runs....\n']);
output = listedoptinfo(c,'soymeal',tenor,'PrintOutput',true);
userData = struct('Underlier',ud.Underlier,...
        'LastCloseDate',ud.LastCloseDate,...
        'LastClosePrice',ud.LastClosePrice,...
        'LastDailyReturn',ud.LastDailyReturn,...
        'Output',output);

obj.UserData = userData;

end