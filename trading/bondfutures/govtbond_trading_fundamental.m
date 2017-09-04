%%
%analyse the historical yield of 10y china govtbond
sec10y = 'GCNY10YR Index';  %china govt bond generic bid yield 10y
sec05y = 'GCNY5YR Index';   %china govt bond generic bid yield 5y
hd05y = history(conn,sec05y,'px_last',dateadd(today,'-10y'),today);
hd10y = history(conn,sec10y,'px_last',dateadd(today,'-10y'),today);
%spd
[t,idx1,idx2] = intersect(hd05y(:,1),hd10y(:,1));
hdspd = [t,hd05y(idx1,2),hd10y(idx2,2),hd10y(idx2,2)-hd05y(idx1,2)];
