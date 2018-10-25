cd('c:\yangyiran\')
%% 登录融航账户
counter_rh = CounterRH.rh_demo_tf;
if ~counter_rh.is_Counter_Login,counter_rh.login;end
entrustsplaced = EntrustArray;
%% 查询账户资金情况
accountinfo = counter_rh.queryAccount;
fprintf('\n');
fprintf('%8s:%12s\n','平盈',num2str(accountinfo.close_profit));
fprintf('%8s:%12s\n','持盈',num2str(accountinfo.position_profit));
fprintf('%s:%12s\n','冻结保证金',num2str(accountinfo.frozen_margin));
fprintf('%7s:%12s\n','保证金',num2str(accountinfo.current_margin));
fprintf('%6s:%12s\n','可用资金',num2str(accountinfo.available_fund));
fprintf('%6s:%12s\n','静态权益',num2str(accountinfo.pre_interest));

%% 查询持仓的情况
fprintf('\n查询持仓信息:\n');
posinfo = counter_rh.queryPositions;
npos = length(posinfo);
for i = 1:npos
    volume = posinfo(i).total_position;
    if volume == 0, continue; end
    if posinfo(i).direction == 1
        buysell = '买';
    elseif posinfo(i).direction == -1
        buysell = '卖';
    end
    fprintf('%10s%5s%5s\n',posinfo(i).asset_code,buysell,...
        num2str(posinfo(i).total_position));
end
%% 查询成交记录
fprintf('\n查询成交记录:\n');
trades = counter_rh.queryTrades;
ntrades = length(trades);
for i = 1:ntrades
    if trades(i).direction == 1
        buysell = '买';
    elseif trades(i).direction == -1
        buysell = '卖';
    end
    fprintf('%10s%5s%4s%10s%15s\n',trades(i).asset_code,buysell,num2str(trades(i).volume),...
        num2str(trades(i).trade_price),trades(i).trade_time);
end
%% 查询市场行情
qms = cQMS;
futs = {'cu1812';'zn1812';'ni1901';'rb1901';'T1812';'IH1811'};
for i = 1:size(futs,1)
    instrument = code2instrument(futs{i});
    qms.registerinstrument(instrument);
end
qms.setdatasource('ctp');
qms.ctplogin('countername','ccb_ly_fut');
%% 
fprintf('\n查询市场行情:\n')
qms.refresh
quotes = qms.getquote;
for i = 1:size(futs,1)
    fprintf('%10s%10s%10s%25s\n',quotes{i}.code_ctp,num2str(quotes{i}.bid1),num2str(quotes{i}.ask1),quotes{i}.update_time2);
end

%% 委托下单 - 买多（开）
entrust = Entrust;
code = 'cu1812';
spread = 1;
instrument = code2instrument(code);
direction = 1;  %委托方向：买:1；卖:-1
q = qms.getquote(code);
px = q.ask1 - spread*instrument.tick_size; %委托价格
volume = 1;     %委托量
offset = 1;     %开/平仓：  开:1；平:-1
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
ret = counter_rh.placeEntrust(entrust);
if ret
    entrustsplaced.push(entrust);
    fprintf('开仓买多-报单编号:%s 执行成功\n',num2str(entrust.entrustNo));
end

%% 委托下单 - 卖空（开）
entrust = Entrust;
code = 'cu1812';
spread = 1;
direction = -1;
q = qms.getquote(code);
px = q.bid1 + spread*instrument.tick_size; %委托价格
volume = 1;
offset = 1;
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
ret = counter_rh.placeEntrust(entrust);
if ret
    entrustsplaced.push(entrust);
    fprintf('开仓卖空-报单编号:%s 执行成功\n',num2str(entrust.entrustNo));
end


%% 委托下单 - 买多（平）
code = 'cu1812';
volume = 1;
spread = 0;
closetodayflag = 1; %平今仓（上期所专用）
positions = counter_rh.queryPositions(code);
if isempty(positions)
    fprintf('买平错误：未发现%s的持仓！！！\n',code);
else
    npos = length(positions);
    if npos > 1
        for i = 1:npos
            pos = positions(i);
            if pos.direction == -1
                break
            end
        end
    else
        pos = positions;
    end
    
    if pos.direction ~= -1
        fprintf('买平错误：仅发现%s的买入持仓！！！\n',code);
    else
        if pos.total_position == 0
            fprintf('买平错误：未发现%s的卖出持仓！！！\n',code);
        else
            available_position = pos.available_position;
            if volume > available_position
                fprintf('空平错误：平仓量超过可平买入持仓量！！！\n')
            else
                entrust = Entrust;
                q = qms.getquote(code);
                px = q.ask1 - spread*instrument.tick_size; %委托价格
                entrust.fillEntrust(1,code,-pos.direction,px,volume,-1,code);
                entrust.assetType = 'Future';
                if closetodayflag, entrust.closetodayFlag = 1;end
                ret = counter_rh.placeEntrust(entrust);
                if ret
                    entrustsplaced.push(entrust);
                    fprintf('买空平仓-报单编号:%s 执行成功\n',num2str(entrust.entrustNo));
                end
            end
        end
    end
end

%% 委托下单 - 卖空（平）
code = 'IH1811';
volume = 1;
spread = 0;
closetodayflag = 1; %平今仓（上期所专用）
positions = counter_rh.queryPositions(code);
if isempty(positions)
    fprintf('空平错误：未发现%s的持仓！！！\n',code);
else
    npos = length(positions);
    if npos > 1
        for i = 1:npos
            pos = positions(i);
            if pos.direction == 1
                break
            end
        end
    else
        pos = positions;
    end
    
    if pos.direction ~= 1
        fprintf('空平错误：仅发现%s的卖出持仓！！！\n',code);
    else
        if pos.total_position == 0
            fprintf('空平错误：未发现%s的买入持仓！！！\n',code);
        else
            available_position = pos.available_position;
            if volume > available_position
                fprintf('空平错误：平仓量超过可平买入持仓量！！！\n')
            else
                entrust = Entrust;
                q = qms.getquote(code);
                px = q.bid1 + spread*instrument.tick_size; %委托价格
                entrust.fillEntrust(1,code,-pos.direction,px,volume,-1,code);
                entrust.assetType = 'Future';
                if closetodayflag, entrust.closetodayFlag = 1;end
                ret = counter_rh.placeEntrust(entrust);
                if ret
                    entrustsplaced.push(entrust);
                    fprintf('卖空平仓-报单编号:%s 执行成功\n',num2str(entrust.entrustNo));
                end
            end
        end
    end
end

%% 查询委托情况
fprintf('\n查询委托情况:\n')
nentrust = entrustsplaced.latest;
for i = 1:nentrust
    entrust_i = entrustsplaced.node(i);
    warning('off')
    ret = counter_rh.queryEntrust(entrust_i);
    if ret
        if entrust_i.is_entrust_closed
            if entrust_i.dealVolume == entrust_i.volume && entrust_i.cancelVolume == 0
                fprintf('\t报单编号 %s 状态：全部成交\n',num2str(entrust_i.entrustNo));
            elseif entrust_i.dealVolume == 0 && entrust_i.cancelVolume == entrust_i.volume
                fprintf('\t报单编号 %s 状态：全部取消\n',num2str(entrust_i.entrustNo));
            elseif entrust_i.dealVolume > 0 && entrust_i.dealVolume < entrust_i.volume && entrust_i.dealVolume + entrust_i.cancelVolume == entrust_i.volume
                fprintf('\t报单编号 %s 状态：部分成交且未成交部分全部取消\n',num2str(entrust_i.entrustNo));
            end
        else
            if entrust_i.dealVolume == 0 && entrust_i.cancelVolume == 0
                fprintf('\t报单编号 %s 状态：全部未成交\n',num2str(entrust_i.entrustNo));
            elseif entrust_i.dealVolume > 0 && entrust.dealVolume < entrust_i.volume && entrust_i.cancelVolume == 0
                fprintf('\t报单编号 %s 状态：部分成交\n',num2str(entrust_i.entrustNo));
            end
        end
    end
end
%% 撤销委托
if ~entrust.is_entrust_closed
    ret = counter_rh.withdrawEntrust(entrust);
    if ret
        fprintf('报单编号 %s 撤单成功\n',num2str(entrust.entrustNo));
    end
end

%% 登出融航
counter_rh.logout;





