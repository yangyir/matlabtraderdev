clc;clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.005);
code = 'IH2002';
instr = code2instrument(code);
mdefut.registerinstrument(instr);
mdefut.setcandlefreq(1440,instr);
%%
checkdt1 = '2020-02-06';
checkdt2 = '2020-02-07';
replay_filenames = {[code,'_',datestr(checkdt1,'yyyymmdd'),'_tick.txt'];...
    [code,'_',datestr(checkdt2,'yyyymmdd'),'_tick.txt']};
mdefut.initreplayer('code',code,'filenames',replay_filenames);
%%
mdefut.initcandles;
%%
mdefut.printflag_ = true;
mdefut.print_timeinterval_ = 30*60;
mdefut.start;
%%
