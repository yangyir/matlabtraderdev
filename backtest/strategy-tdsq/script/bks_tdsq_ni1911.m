%% perfect
tradesperfect = bkf_gentrades_tdsqperfect('ni1911',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('perfect trades:\n');
bkf_printtrades_tdsq(tradesperfect);
%% imperfect
tradesimperfect = bkf_gentrades_tdsqimperfect('ni1911',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,...
    'riskmode','macd',...
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
fprintf('avg loose pnl:%4.1f\n',lossavgpnl);
%% single lvlup
tradessinglelvlup = bkf_gentrades_tdsqsinglelvlup('ni1911',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('single lvlup trades:\n');
bkf_printtrades_tdsq(tradessinglelvlup);
%% single lvldn
tradessinglelvldn = bkf_gentrades_tdsqsinglelvldn('ni1911',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('single lvldn trades:\n');
bkf_printtrades_tdsq(tradessinglelvldn);
%% double range
tradesdoublerange = bkf_gentrades_tdsqdoublerange('ni1911',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('double range trades:\n');
bkf_printtrades_tdsq(tradesdoublerange);
[kelly,W] = kellyratio(tradesdoublerange)
%%
tradesdoublebullish = bkf_gentrades_tdsqdoublebullish('ni1911',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('double bullish trades:\n');
bkf_printtrades_tdsq(tradesdoublebullish);
%%
tradesdoublebearish = bkf_gentrades_tdsqdoublebearish('ni1911',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('double bearish trades:\n');
bkf_printtrades_tdsq(tradesdoublebearish);
