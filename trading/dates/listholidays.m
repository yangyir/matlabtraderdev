function holidays = listholidays(city)
%list holidays between this year and next year for a given holiday city
%Shanghai 'SHFE'
%Hongkong'HKEX'
%Taiwan'TWSE'
%Newyork-'NYSE'
%Tokyo'TSE'
%London'LSE'
%return dates in EXCEL format
if all(~strcmpi(city,{'shanghai','hongkong','taiwan','newyork','tokyo','london'}))
    error('listholiday:invalid city')
end

answer = who('w');
if isempty(answer)
    w=windmatlab;        
end

yyyy = year(today);
dStart = [num2str(yyyy),'-01-01'];
dEnd = [num2str(yyyy),'-12-31'];
dNStart = datenum(dStart,'yyyy-mm-dd');
dNEnd = datenum(dEnd,'yyyy-mm-dd');
dCalendar = dNStart:1:dNEnd;dCalendar=dCalendar';
if strcmpi(city,'shanghai')
    dBusiness = datenum(w.tdays(dStart,dEnd,'TradingCalendar=SHFE'));
elseif strcmpi(city,'hongkong')
    dBusiness = datenum(w.tdays(dStart,dEnd,'TradingCalendar=HKEX'));
elseif strcmpi(city,'taiwan')
    dBusiness = datenum(w.tdays(dStart,dEnd,'TradingCalendar=TWSE'));
elseif strcmpi(city,'newyork')
    dBusiness = datenum(w.tdays(dStart,dEnd,'TradingCalendar=NYSE'));
elseif strcmpi(city,'tokyo')
    dBusiness = datenum(w.tdays(dStart,dEnd,'TradingCalendar=TSE'));
elseif strcmpi(city,'london')
    dBusiness = datenum(w.tdays(dStart,dEnd,'TradingCalendar=LSE'));
else
    error('invalid city')
end
   
idx = zeros(length(dCalendar),1);
for i=1:length(dCalendar)
    answer = find(dBusiness==dCalendar(i), 1);
    if isempty(answer)
        idx(i)=1;
    end
end
dNonBusiness = dCalendar(idx==1);
%now remove weekend days
dNum = weekday(dNonBusiness);
dNonBusiness = dNonBusiness(dNum~=1);
dNum = weekday(dNonBusiness);
dNonBusiness = dNonBusiness(dNum~=7);

%output
holidays = m2xdate(dNonBusiness);

end