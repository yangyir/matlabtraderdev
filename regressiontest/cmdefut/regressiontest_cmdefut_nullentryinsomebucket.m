clc;clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.05/50);
code = 'cu1907';
instr = code2instrument(code);
mdefut.registerinstrument(instr);
mdefut.setcandlefreq(15,instr);
checkdt = '2019-06-10';
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.txt'];
mdefut.initreplayer('code',code,'fn',replay_filename);
mdefut.initcandles;
mdefut.print_timeinterval_ = 15*60;
%%
mdefut.start;