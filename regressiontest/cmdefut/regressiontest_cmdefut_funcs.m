mdefut = cMDEFut;
mdefut.login('Connection','CTP','CounterName','citic_kim_fut');
%%
code = 'T1812';
mdefut.registerinstrument(code);
mdefut.setcandlefreq(15,code)
mdefut.settechnicalindicatorautocalc(code,1);
params = struct('name','WilliamR','values',{{'numofperiods',144}});
mdefut.settechnicalindicator(code,params);
mdefut.calc_technical_indicators(code);
% 错误使用 willpctr (line 85)
% NPERIODS is too large for the number of data available.
% 
% 出错 cMDEFut/calc_wr_ (line 44)
%     indicators = willpctr(highp,lowp,closep,nperiods);
% 
% 出错 cMDEFut/calc_technical_indicators (line 22)
%                         wr = calc_wr_(mdefut,instrument,val{:});

%%
mdefut.refresh
%%
mdefut.printmarket

%%
mdefut.logoff;
