%% ctp login
% if ~exist('md_ctp','var') || ~isa(md_ctp,'cCTP')
%     md_ctp = cCTP.citic_kim_fut;
% end
% if ~md_ctp.isconnect, md_ctp.login; end

if ~exist('qms_demo_cmde','var') || ~isa(qms_demo_cmde,'cQMS')
    qms_demo_cmde = cQMS;
    qms_demo_cmde.setdatasource('local');
end

%% contracts
ni1801 = cFutures('ni1801');ni1801.loadinfo('ni1801_info.txt');
zn1801 = cFutures('zn1801');zn1801.loadinfo('zn1801_info.txt');
% al1712 = cFutures('al1712');al1712.loadinfo('al1712_info.txt');

%% init market data engine
mde_fut = cMDEFut;
mde_fut.qms_ = qms_demo_cmde;
mde_fut.registerinstrument(ni1801);
mde_fut.registerinstrument(zn1801);
% mde_fut.registerinstrument(al1712);

% mde_fut.initcandles;

%%
mde_fut.startat('2017-10-24 09:00:00');

%%
mde_fut.start;

%%
mde_fut.stop;

%%
trading_freq = 3;
mde_fut.setreplaydate('2017-10-23');
mde_fut.setcandlefreq(trading_freq);


