%% perfect
tradesperfect = bkf_gentrades_tdsqperfect('au1912',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('perfect trades:\n');
bkf_printtrades_tdsq(tradesperfect);
%% imperfect
tradesimperfect = bkf_gentrades_tdsqimperfect('au1912',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd','openapproach','new');
fprintf('imperfect trades:\n');
bkf_printtrades_tdsq(tradesimperfect);
%% single lvlup
tradessinglelvlup = bkf_gentrades_tdsqsinglelvlup('au1912',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('single lvlup trades:\n');
bkf_printtrades_tdsq(tradessinglelvlup);
%% single lvldn
tradessinglelvldn = bkf_gentrades_tdsqsinglelvldn('au1912',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('single lvldn trades:\n');
bkf_printtrades_tdsq(tradessinglelvldn);
%% double range
tradesdoublerange = bkf_gentrades_tdsqdoublerange('au1912',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('double range trades:\n');
bkf_printtrades_tdsq(tradesdoublerange);
%%
tradesdoublebullish = bkf_gentrades_tdsqdoublebullish('au1912',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('double bullish trades:\n');
bkf_printtrades_tdsq(tradesdoublebullish);
%%
tradesdoublebearish = bkf_gentrades_tdsqdoublebearish('au1912',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('double bearish trades:\n');
bkf_printtrades_tdsq(tradesdoublebearish);
