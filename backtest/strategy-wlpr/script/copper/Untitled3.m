ui_freq = 15;
dir_ = [getenv('OneDrive'),'\backtest\copper\'];
fn = ['copper_intraday_',num2str(ui_freq),'m'];
data = load([dir_,fn]);
candles = data.(['candles_',num2str(ui_freq),'m']);
nfut = size(candles,1);

%%
clc;
ifut = 23;
code = candles{ifut,1};
instrument = code2instrument(code);
p = candles{ifut,2};
np = size(p,1);
ret = zeros(np,1);
[tdbuysetup,tdsellsetup,tdstresistence,tdstsupport,tdbuycountdown,tdsellcountdown] = tdsq(p);
[lead,lag] = movavg(p(:,5),12,26,'e');
macdvec = lead - lag;
[~,nineperma] = movavg(macdvec,1,9,'e');

for i = 1:np
    ret(i) = tdsq_isvalidbreach(i,p,tdbuysetup,tdsellsetup,tdstresistence,tdstsupport);
    if i > 1 && ret(i) == ret(i-1)
        continue;
    end
    if ret(i) ~= 0
        if ret(i) == 1
            fprintf('%4s:%2s\ttdsellsetup:%s\n',num2str(i),num2str(ret(i)),num2str(tdsellsetup(i)));
        else
            fprintf('%4s:%2s\tdbuysetup:%s\n',num2str(i),num2str(ret(i)),num2str(tdbuysetup(i)));
        end
    end
end

%   88: 1	tdsellsetup:5
%  103:-1	dbuysetup:2
%  111:-1	dbuysetup:3
%  248:-1	dbuysetup:2
%  279:-1	dbuysetup:6
%  325: 1	tdsellsetup:8
%  332:-1	dbuysetup:3
%  377:-1	dbuysetup:9
%  390: 1	tdsellsetup:3
%  400:-1	dbuysetup:4
%  405: 1	tdsellsetup:3
%  408:-1	dbuysetup:3
%  420: 1	tdsellsetup:3
%  427: 1	tdsellsetup:2
%  436:-1	dbuysetup:3
%  440: 1	tdsellsetup:3
%  483:-1	dbuysetup:2
%  562:-1	dbuysetup:9
%  719:-1	dbuysetup:3
%  853: 1	tdsellsetup:2
%  872: 1	tdsellsetup:2
%  875: 1	tdsellsetup:5
%  899:-1	dbuysetup:3


%%
idxstart = 875;
tdsq_plot2(p,max(idxstart-1,1),min(idxstart+200,np),instrument);
%%
tdsq_isvalidbreach(874,p,tdbuysetup,tdsellsetup,tdstresistence,tdstsupport)
