%%
doctor_ni1910;
%% perfect
tradesperfect = bkf_gentrades_tdsqperfect('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('perfect trades:\n');
bkf_printtrades_tdsq(tradesperfect);
[ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradesperfect);
fprintf('kelly ratio:%4.1f\n',ratio);
fprintf('winning prob:%4.1f%%\n',W*100);
fprintf('avg win pnl:%4.1f\n',winavgpnl);
fprintf('avg loos pnl:%4.1f\n',lossavgpnl);

%% imperfect
tradesimperfect = bkf_gentrades_tdsqimperfect('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd',...
    'rangereverselimit',18,...
    'rangebreachlimit',12,...
    'usetrendbreach',true,...
    'usesetupscenario',true,...
    'closeonperfect',false);
fprintf('imperfect trades:\n');
bkf_printtrades_tdsq(tradesimperfect);
[ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradesimperfect);
fprintf('kelly ratio:%4.1f\n',ratio);
fprintf('winning prob:%4.1f%%\n',W*100);
fprintf('avg win pnl:%4.1f\n',winavgpnl);
fprintf('avg loos pnl:%4.1f\n',lossavgpnl);

%% single lvlup
tradessinglelvlup = bkf_gentrades_tdsqsinglelvlup('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('single lvlup trades:\n');
bkf_printtrades_tdsq(tradessinglelvlup);
[ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradessinglelvlup);
fprintf('kelly ratio:%4.1f\n',ratio);
fprintf('winning prob:%4.1f%%\n',W*100);
fprintf('avg win pnl:%4.1f\n',winavgpnl);
fprintf('avg loos pnl:%4.1f\n',lossavgpnl);

%% single lvldn
tradessinglelvldn = bkf_gentrades_tdsqsinglelvldn('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('single lvldn trades:\n');
bkf_printtrades_tdsq(tradessinglelvldn);
[ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradessinglelvldn);
fprintf('kelly ratio:%4.1f\n',ratio);
fprintf('winning prob:%4.1f%%\n',W*100);
fprintf('avg win pnl:%4.1f\n',winavgpnl);
fprintf('avg loos pnl:%4.1f\n',lossavgpnl);

%% double range
tradesdoublerange = bkf_gentrades_tdsqdoublerange('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('double range trades:\n');
bkf_printtrades_tdsq(tradesdoublerange);
[ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradesdoublerange);
fprintf('kelly ratio:%4.1f\n',ratio);
fprintf('winning prob:%4.1f%%\n',W*100);
fprintf('avg win pnl:%4.1f\n',winavgpnl);
fprintf('avg loos pnl:%4.1f\n',lossavgpnl);

%%
tradesdoublebullish = bkf_gentrades_tdsqdoublebullish('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('double bullish trades:\n');
bkf_printtrades_tdsq(tradesdoublebullish);
[ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradesdoublebullish);
fprintf('kelly ratio:%4.1f\n',ratio);
fprintf('winning prob:%4.1f%%\n',W*100);
fprintf('avg win pnl:%4.1f\n',winavgpnl);
fprintf('avg loos pnl:%4.1f\n',lossavgpnl);

%%
tradesdoublebearish = bkf_gentrades_tdsqdoublebearish('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('double bearish trades:\n');
bkf_printtrades_tdsq(tradesdoublebearish);
[ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradesdoublebearish);
fprintf('kelly ratio:%4.1f\n',ratio);
fprintf('winning prob:%4.1f%%\n',W*100);
fprintf('avg win pnl:%4.1f\n',winavgpnl);
fprintf('avg loos pnl:%4.1f\n',lossavgpnl);

%%
tradessimpletrend = bkf_gentrades_simpletrend('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('simple trades:\n');
bkf_printtrades_tdsq(tradessimpletrend);
[ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradessimpletrend);
fprintf('kelly ratio:%4.1f\n',ratio);
fprintf('winning prob:%4.1f%%\n',W*100);
fprintf('avg win pnl:%4.1f\n',winavgpnl);
fprintf('avg loos pnl:%4.1f\n',lossavgpnl);
