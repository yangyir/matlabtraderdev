clc;
clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.005);
%%
code = 'cu1907';
instr = code2instrument(code);
mdefut.registerinstrument(instr);
mdefut.setcandlefreq(15,instr);
%%
checkdt = '2019-06-11';
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.txt'];
mdefut.initreplayer('code',code,'fn',replay_filename);
%%
mdefut.initcandles(instr);
%%
[~,~,levelup,leveldn] = mdefut.calc_tdsq_(instr,'includelastcandle',1);
fprintf('levelup:%6d\n',levelup(end));
fprintf('leveldn:%6d\n',leveldn(end));
%%
[macdvec,sig,diffbar] = mdefut.calc_macd_(instr,'includelastcandle',1);
fprintf('macdvec:%6.2f\n',macdvec(end));
fprintf('sig:%6.2f\n',sig(end));
%%
mdefut.start;

