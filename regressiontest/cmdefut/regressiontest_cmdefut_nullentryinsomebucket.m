clc;clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.05/50);
code = 'cu1907';
instr = code2instrument(code);
mdefut.registerinstrument(instr);
mdefut.setcandlefreq(1,instr);
checkdt = '2019-06-10';
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.txt'];
mdefut.initreplayer('code',code,'fn',replay_filename);
mdefut.print_timeinterval_ = 5*60;
%%
mdefut.start;