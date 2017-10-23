%% ctp login
% if ~exist('md_ctp','var') || ~isa(md_ctp,'cCTP')
%     md_ctp = cCTP.citic_kim_fut;
% end
% if ~md_ctp.isconnect, md_ctp.login; end

if ~exist('qms_fut','var') || ~isa(qms_fut,'cQMS')
    qms_fut = cQMS;
    qms_fut.setdatasource('local');
end

%% contract
ni1801 = cFutures('ni1801');ni1801.loadinfo('ni1801_info.txt');
zn1801 = cFutures('zn1801');zn1801.loadinfo('zn1801_info.txt');

%% pre-download data
dtstart = '2017-10-16 09:00:00';
dtend = '2017-10-23 08:59:00';
ds = cBloomberg;
minutebar = ds.intradaybar(ni1801,dtstart,dtend,1,'trade');

%%
trade_freq = 3;
% histcandles = timeseries_compress([minutebar(:,1),minutebar(:,5)],...
%     'tradinghours',ni1801.trading_hours,'tradingbreak',ni1801.trading_break,...
%     'frequency',[num2str(trade_freq),'m']);

%%
mde_ni1801 = cMDEFut;
mde_ni1801.qms_ = qms_fut;
mde_ni1801.registerinstrument(ni1801);
mde_ni1801.registerinstrument(zn1801);
mde_ni1801.setcandlefreq(trade_freq,ni1801);
mde_ni1801.setcandlefreq(trade_freq,zn1801);
mde_ni1801.initcandles;


%%
% % in case the mde starts inproperly and we need to fill in the candles as
% % required
% dtstart_ = '2017-10-23 09:00:00';
% dtend_ = '2017-10-23 11:30:00';
% minutebar_ = ds.intradaybar(ni1801,dtstart_,dtend_,trade_freq,'trade');
% n = size(mde_ni1801.candles_{1},1);
% dtstartnum_ = datenum(dtstart_);
% dtendnum_ = datenum(dtend_);
% for i = 1:n
%     bucket = mde_ni1801.candles_{1}(i,1);
%     close = mde_ni1801.candles_{1}(i,5);
%     if bucket < dtendnum_ && bucket >= dtstartnum_ && close == 0
%         %we need to fill in the bucket
%         idx = minutebar_ == bucket;
%         d = minutebar_(idx,:);
%         if ~isempty(d)
%             mde_ni1801.candles_{1}(i,2:end) = d(:,2:end);
%         end
%     end
% end

%%

%%
mde_ni1801.start;

%%
mde_ni1801.startat('2017-10-23 13:30:00');

%%
candles = mde_ni1801.candles_{1};

%%
indicators = mde_ni1801.calc_technical_indicator('William %R',ni1801,'NumOfPeriods',144);

%%
mde_ni1801.stop;
%% ctp logoff
if exist('md_ctp','var')
    try
        md_ctp.logoff;
        clear md_ctp;
    catch e
        fprintf([e.message,'\n']);
    end 
end

if exist('qms_fut','var'), clear qms_fut; end


%%
codes = {'ni1801';'al1712';'zn1801';'T1712'};
ncodes = size(codes,1);
% William %R
WilliamR = ones(ncodes,1);
techtbl = table(WilliamR,'RowNames',codes);

