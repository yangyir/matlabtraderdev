% w = cWind;
%%
etf50 = code2instrument('510050');
etf300 = code2instrument('510300');
etf500 = code2instrument('510500');
%%
m_etf = cMDEFut;
m_etf.login('connection','wind');
m_etf.registerinstrument(etf50);
m_etf.registerinstrument(etf300);
m_etf.registerinstrument(etf500);
m_etf.setcandlefreq(30,etf50);
m_etf.setcandlefreq(30,etf300);
m_etf.setcandlefreq(30,etf500);
%%
m_etf.initcandles(etf50);
m_etf.initcandles(etf300);
m_etf.initcandles(etf500);
%%
m_etf.settimerinterval(0.005);
m_etf.printflag_ = true;
m_etf.print_timeinterval_ = 60*10;
%%
m_etf.start;

