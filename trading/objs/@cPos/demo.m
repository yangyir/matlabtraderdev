%demo_cPos
function [] = demo()
clc;
pos = cPos;
dt1 = businessdate(getlastbusinessdate,-1);
dt2 = getlastbusinessdate;
dt1str = datestr(dt1,'yyyy-mm-dd');
dt2str = datestr(dt2,'yyyy-mm-dd');
fprintf('open short position at price 2870 with 10 lots on %s\n',dt1str);
pos.override('code','m1805','price',2870,'volume',-10,'time',dt1);
%the market close at 2871 and we reset the carry price as of 2871.
pos.cost_carry_ = 2871;
pos.print;
fprintf('$\n');
%%
fprintf('open short position at price 2877 with 20 lots on %s\n',[dt2str,' 11:15:00']);
pos.add('code','m1805','price',2877,'volume',-20,'time',datenum([dt2str,' 11:15:00']));
pos.print;
fprintf('$\n');
%%
fprintf('close 5 lots of short at price 2861 on %s\n',[dt2str,' 14:50:00']);
pos.add('code','m1805','price',2861,'volume',5,'time',datenum([dt2str,' 14:50:00']));
pos.print;
fprintf('$\n');
%%
fprintf('close 5 lots of today short at price 2855 on %s\n',[dt2str,' 14:55:00']);
pos.add('code','m1805','price',2855,'volume',5,'time',datenum([dt2str,' 14:55:00']),'closetodayflag',1);
pos.print;
fprintf('$\n');
%%
fprintf('close 16 lots of short at price 2851 on %s\n',[dt2str,' 14:59:00']);
pos.add('code','m1805','price',2851,'volume',16,'time',datenum([dt2str,' 14:59:00']));
pos.print;
fprintf('$\n');
fprintf('demo finishes......\n');
end