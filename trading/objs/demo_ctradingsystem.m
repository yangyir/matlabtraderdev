
%% set a single futures
code = 'au1712';
fut = cFutures('au1712');
fut.loadinfo([code,'_info.txt']);

%%
clear ts;

%%
% init trading system
strat = cStratFutSingleSyntheticOpt;
qms = cQMS;
counter = CounterCTP.citic_kim_fut;
ts = cTradingSystem;
ts.init(strat,qms,counter);

%%
% register instrument
ts.registerinstrument(fut);

%% register strategy
strat.addoptleg('p',1,'2017-12-15',1e6,0.16/sqrt(252));

%%
%set qms connection
qms.setdatasource('ctp');
fprintf('\n');
fprintf('qms connected:%s\n',num2str(ts.isqmsconnect));
%first time connection
qms.refresh;
q = qms.getquote(fut);
q.print;

%%
%load init positions from counter
%or once the entrust is filled we will load the position from the counter
%to update the trading system portfolio
ts.loadportfoliofromcounter;
disp(ts.portfolio_);

%%
ts.counterlogoff

%%
%withdraw all pending entrusts
ts.withdrawpendingentrusts;

%% demo to gen signal once
signals = ts.gensignal;
signals{1}

%% demo to place entrust
ts.placenewentrusts(signals)

%% demo to trade once
% essentially this is a combo of gensignal,withdraw pending entrusts and
% place new entrusts
ts.manualtrade;

%todo: we shall update the position after being notified that the entrust
%is fulfilled


%%
clear;