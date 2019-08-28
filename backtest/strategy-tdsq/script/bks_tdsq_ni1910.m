%% perfect
tradesperfect = bkf_gentrades_tdsqperfect('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('perfect trades:\n');
bkf_printtrades_tdsq(tradesperfect);
%% imperfect
tradesimperfect = bkf_gentrades_tdsqimperfect('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('imperfect trades:\n');
bkf_printtrades_tdsq(tradesimperfect);
%% single lvlup
tradessinglelvlup = bkf_gentrades_tdsqsinglelvlup('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('single lvlup trades:\n');
bkf_printtrades_tdsq(tradessinglelvlup);
%% single lvldn
tradessinglelvldn = bkf_gentrades_tdsqsinglelvldn('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd-setup');
fprintf('single lvldn trades:\n');
bkf_printtrades_tdsq(tradessinglelvldn);
%% double range
tradesdoublerange = bkf_gentrades_tdsqdoublerange('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd');
fprintf('double range trades:\n');
bkf_printtrades_tdsq(tradesdoublerange);