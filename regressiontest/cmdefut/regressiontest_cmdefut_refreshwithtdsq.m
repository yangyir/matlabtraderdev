clc;clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.05/50);
code = 'T1909';
instr = code2instrument(code);
mdefut.registerinstrument(instr);
freqnum = 15;%15-minute interval
mdefut.setcandlefreq(freqnum,instr);
mdefut.print_timeinterval_ = freqnum*60;
checkdt = '2019-06-12';
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.txt'];
mdefut.initreplayer('code',code,'fn',replay_filename);
mdefut.initcandles;
%%
mdefut.calc_wr_(instr)
%%
hc = mdefut.gethistcandles(instr);hc = hc{1};
tdsq_plot2(hc,1,size(hc,1),instr);
%%
mdefut.start;
%%
mdefut.stop;
