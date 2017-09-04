%calculate public holidays in China since 2010;
c = bbgconnect;
sec = 'SHCOMP Index';
field = 'px_last';
dateFrom = '01-Jan-2010';
dateTo = '31-Dec-2016';

d = history(c,sec,field,dateFrom,dateTo);

busDates = d(:,1);
allDates = datenum(dateFrom):1:datenum(dateTo);
allDates = allDates';

%setdiff returns the data in allDates but not in busDates;
holidays = setdiff(allDates,busDates);
wd = weekday(holidays);
idx = wd ~= 1 & wd ~= 7;
holidays = holidays(idx);

c.close;