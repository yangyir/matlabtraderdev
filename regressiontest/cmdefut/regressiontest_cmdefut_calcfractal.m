clc;
clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.005);
%%
code = 'IH2002';
instr = code2instrument(code);
mdefut.registerinstrument(instr);
mdefut.setcandlefreq(30,instr);
%%
checkdt = '2020-02-07';
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.txt'];
mdefut.initreplayer('code',code,'fn',replay_filename);
%
mdefut.initcandles(instr);
%%
candlesticks = mdefut.getallcandles(instr);
p = candlesticks{1};
outputmat = tools_technicalplot1(p,mdefut.nfractals_(1),1);
fprintf('HH:%s\n',num2str(outputmat(end,7)));
fprintf('LL:%s\n',num2str(outputmat(end,8)));
fprintf('jaw:%6.2f\n',outputmat(end,9));
fprintf('teeth:%6.2f\n',outputmat(end,10));
fprintf('lips:%6.2f\n',outputmat(end,11));

%%
[~,HH,LL] = mdefut.calc_fractal_(instr,'includelastcandle',1);
fprintf('HH:%s\n',num2str(HH(end)));
fprintf('LL:%s\n',num2str(LL(end)));
%%
[jaw,teeth,lips] = mdefut.calc_alligator_(instr,'includelastcandle',1);
fprintf('jaw:%6.2f\n',jaw(end));
fprintf('teeth:%6.2f\n',teeth(end));
fprintf('lips:%6.2f\n',lips(end));
%%
mdefut.print_timeinterval_ = 30*60;
mdefut.start;

