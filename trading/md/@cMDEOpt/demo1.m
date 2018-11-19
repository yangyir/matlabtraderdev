code = 'cu1901P48000';
instrument = code2instrument(code);


p = {'cu1901P48000';'cu1901P49000';'cu1901P50000'};
c = {'cu1901C48000';'cu1901C49000';'cu1901C50000'};

mdeopt = cMDEOpt;
for i = 1:3
    mdeopt.registerinstrument(p{i});
    mdeopt.registerinstrument(c{i});
end
%%
mdeopt.login('connection','ctp','countername','ccb_ly_fut');
%%
mdeopt.start
%%
res = mdeopt.getgreeks(code)
%%
output = pnlriskbreakdown1(code,getlastbusinessdate)