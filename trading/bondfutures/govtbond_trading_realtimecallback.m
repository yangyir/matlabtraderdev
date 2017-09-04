function govtbond_trading_realtimecallback(obj,event,conn,rollinfo5y,rollinfo10y)
%callback function to retrieve govtbond pricing from bloomberg

%note:the callback function shall run if and only if it is within market
%trading hours
dt = datenum(event.Data.time);
day = floor(dt);


if isholiday(day)
    set(obj,'UserData',{});
    return
end

%bond trading hours
%09:15 to 11:30
%13:00 to 15:15
%we have 1 min buffer zone as a proxy
tStart1 = datenum([datestr(day),' 09:15:00']);
tStop1 = datenum([datestr(day),' 11:31:00']);
tStart2 = datenum([datestr(day),' 13:00:00']);
tStop2 = datenum([datestr(day),' 15:16:00']);

if ~((dt >= tStart1 && dt <= tStop1) ||...
        (dt >= tStart2 && dt <= tStop2))
    fprintf([datestr(event.Data.time),' timer runs....']);
    fprintf('bond futures market closed...\n');
    return
end
    

fprintf([datestr(event.Data.time),' timer runs....\n']);

if isempty(obj.UserData)
    count = 0;
else
    ud = obj.UserData;
    count = ud.Count;
    tsOld = ud.TimeSeries;
end

userData = govtbond_trading_realtimeinfo(conn,rollinfo5y,rollinfo10y);
% userData = getdata(conn,'XAU Curncy','px_last');

count = count + 1;
tsNew = zeros(count,3);
if count > 1
    tsNew(1:count-1,:) = tsOld;
end
tsNew(count,1) = dt;
tsNew(count,2) = count;
% tsNew(count,3) = userData.px_last;
tsNew(count,3) = userData.YldSlopeChg;

obj.UserData = struct('Count',count,...
    'Data',userData,...
    'TimeSeries',tsNew);
figure(1);
grid on;
plot(tsNew(:,2),tsNew(:,3),'b');
axis([0 280 -inf inf]);
hold on;

end