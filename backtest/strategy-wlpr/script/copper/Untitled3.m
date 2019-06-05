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



%%
idxstart = 400;
tdsq_plot(p,idxstart,min(idxstart+200,np),instrument);
    



%%
for i = nperiodwr+1:np
    pmax = max(p(i-nperiodwr:i-1,3));
    pmin = min(p(i-nperiodwr:i-1,4));
    phigh = p(i,3);
    plow = p(i,4);
    newmax = phigh > pmax;
    newmin = plow < pmin;
    if newmax
        for j = i+1:np
            if p(j,3) > phigh,break;end
            if macd(j) < nineperma(j)
                ntrade = ntrade + 1;
                trades(ntrade,1) = -1;
                trades(ntrade,2) = j;
                break
            end
        end
    end
    
    if newmin
        for j = i+1:np
            if p(j,4) < plow,break;end
            if macd(j) > nineperma(j)
                ntrade = ntrade + 1;
                trades(ntrade,1) = 1;
                trades(ntrade,2) = j;
                break
            end
        end
    end
end
trades = trades(1:ntrade,:);