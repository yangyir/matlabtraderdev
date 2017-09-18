%% counter
if ~(exist('c_ly','var') && isa(c_ly,'CounterCTP')), c_ly = CounterCTP.huaxin_liyang_fut; c_ly.login; end
if ~c_ly.is_Counter_Login, c_ly.login; end

%% watcher
if ~(exist('w','var') && isa(w,'cWactcher')), w = cWatcher; w.conn = 'bloomberg'; end

%% register instruments
codes = {'TF1712';'T1712';'m1801-C-2700';'m1801-P-2700';'m1801-C-2750';'m1801-P-2750';'m1801'};
instruments = cell(length(codes),1);
for i = 1:length(codes)
    flag = isoptchar(codes{i});
    if ~flag
        instruments{i} = cFutures(codes{i});
    else
        instruments{i} = cOption(codes{i});
    end
%     instruments{i}.loadinfo([codes{i},'_info.txt']);
    instruments{i}.init(w.ds);
    w.addsingle(instruments{i}.code_ctp);
end

%%
w.printquotes
spd_bid = (w.qs{2}.yield_ask1 - w.qs{1}.yield_bid1)*100;
spd_ask = (w.qs{2}.yield_bid1 - w.qs{1}.yield_ask1)*100;
spd_trade = (w.qs{2}.yield_last_trade - w.qs{1}.yield_last_trade)*100;
fprintf('yield spread trade:%2.1f;bid:%2.1f;ask:%2.1f\n',spd_trade,spd_bid,spd_ask);

%% trade with just one leg
%%
% place entrust on single leg
idx = 1;
instrument = instruments{idx};
w.refresh;
last_trade = w.qs{idx}.last_trade;

direction = 1;
volume = 1;
offset = 1;
num_ticks = 3;

if direction > 0
    %place a buy order with lower price
    price = last_trade - num_ticks*instrument.tick_size;
elseif direction < 0
    %place a sell order with higher price
    price = last_trade + num_ticks*instrument.tick_size;
end

%first to withdraw pending entrust
% withdrawpendingentrusts(counter,instrument.code_ctp)
if volume > 0
    e = Entrust;
    e.fillEntrust(1,instrument.code_ctp,direction,price,abs(volume),offset,instrument.code_ctp);
    c_ly.placeEntrust(e);
end

%%
withdrawpendingentrusts(c_ly,instruments{idx}.code_ctp);

%%
%trade the spread
volume1 = 9;
volume2 = 5;
tick_size1 = instruments{1}.tick_size;
tick_size2 = instruments{2}.tick_size;

%% open new positions
% long spread:i.e. long TF and short T
w.refresh;
direction1 = 1;
direction2 = -1;
offset1 = 1;
offset2 = 1;
last_trade1 = w.qs{1}.last_trade;
last_trade2 = w.qs{2}.last_trade;
num_ticks = 1;

if direction1 > 0    
    price1 = last_trade1 - num_ticks*tick_size1;
elseif direction1 < 0
    price1 = last_trade1 + num_ticks*tick_size1;
end

if direction2 > 0    
    price2 = last_trade2 - num_ticks*tick_size2;
elseif direction2 < 0
    price2 = last_trade2 + num_ticks*tick_size2;
end

if volume1 > 0
    e1 = Entrust;
    e1.fillEntrust(1,instruments{1}.code_ctp,direction1,price1,abs(volume1),offset1,instruments{1}.code_ctp);
    c_ly.placeEntrust(e1);
end

if volume2 > 0
    e2 = Entrust;
    e2.fillEntrust(1,instruments{2}.code_ctp,direction2,price2,abs(volume2),offset2,instruments{2}.code_ctp);
    c_ly.placeEntrust(e2);
end

%%
% withdraw entrust
withdrawpendingentrusts(c_ly,instruments{1}.code_ctp);
% withdrawpendingentrusts(c_ly,instruments{2}.code_ctp);

%%
pos1 = c_ly.queryPositions(instruments{1}.code_ctp);
pos2 = c_ly.queryPositions(instruments{2}.code_ctp);
disp(pos1);
disp(pos2);

%%
% query account
c_ly.queryAccount

%%
c_ly.logout;




