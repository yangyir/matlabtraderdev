cd('c:\yangyiran\')
%% 登录融航账户
counter_rh = cCounterRH.rh_demo;
if ~counter_rh.is_Counter_Login,counter_rh.login;end

%% 查询账户资金情况
accountinfo = counter_rh.queryAccount;
fprintf('\n');
fprintf('%8s:%12s\n','平盈',num2str(accountinfo.close_profit));
fprintf('%8s:%12s\n','持盈',num2str(accountinfo.position_profit));
fprintf('%s:%12s\n','冻结保证金',num2str(accountinfo.frozen_margin));
fprintf('%7s:%12s\n','保证金',num2str(accountinfo.current_margin));
fprintf('%6s:%12s\n','可用资金',num2str(accountinfo.available_fund));
fprintf('%6s:%12s\n','静态权益',num2str(accountinfo.pre_interest));

%% 委托下单 - 买多（开）
entrust = Entrust;
code = 'IC1809';
direction = 1;  %委托方向：买:1；卖:-1
px = 4585;      %委托价格      
volume = 1;     %委托量
offset = 1;     %开/平仓：  开:1；平:-1
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
ret = counter_rh.placeEntrust(entrust);
if ret, fprintf('开仓买多-报单编号:%s 执行成功\n',num2str(entrust.entrustNo));end

%% 委托下单 - 卖空（开）
entrust = Entrust;
code = 'rb1901';
direction = -1;
px = 4135;
volume = 1;
offset = 1;
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
ret = counter_rh.placeEntrust(entrust);
if ret, fprintf('开仓卖空-报单编号:%s 执行成功\n',num2str(entrust.entrustNo));end

%% 委托下单 - 买多（平）
%注释：需要检查持仓信息，目前queryPositions有问题，需本地记录持仓
entrust = Entrust;
code = 'rb1901';
direction = 1;
px = 4130;
volume = 2;
offset = -1;
%平今仓（上期所专用）
closetodayflag = 1;
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
if closetodayflag, entrust.closetodayFlag = 1;end
ret = counter_rh.placeEntrust(entrust);
if ret, fprintf('平仓买多-报单编号:%s 执行成功\n',num2str(entrust.entrustNo));end

%% 委托下单 - 卖空（平）
%注释：需要检查持仓信息，目前queryPositions有问题，需本地记录持仓
entrust = Entrust;
code = 'IC1809';
direction = -1;
px = 4585;
volume = 1;
offset = -1;
%平今仓（上期所专用）
closetodayflag = 1;
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
if closetodayflag, entrust.closetodayFlag = 1;end
ret = counter_rh.placeEntrust(entrust);
if ret, fprintf('平仓卖空-报单编号:%s 执行成功\n',num2str(entrust.entrustNo));end

%% 查询委托情况
warning('off')
ret = counter_rh.queryEntrust(entrust);
if ret
    if entrust.is_entrust_closed
        if entrust.dealVolume == entrust.volume && entrust.cancelVolume == 0
            fprintf('报单编号 %s 状态：全部成交\n',num2str(entrust.entrustNo));
        elseif entrust.dealVolume == 0 && entrust.cancelVolume == entrust.volume
            fprintf('报单编号 %s 状态：全部取消\n',num2str(entrust.entrustNo));
        elseif entrust.dealVolume > 0 && entrust.dealVolume < entrust.volume && entrust.dealVolume + entrust.cancelVolume == entrust.volume
            fprintf('报单编号 %s 状态：部分成交且未成交部分全部取消\n',num2str(entrust.entrustNo));
        end
    else
        if entrust.dealVolume == 0 && entrust.cancelVolume == 0
            fprintf('报单编号 %s 状态：全部未成交\n',num2str(entrust.entrustNo));
        elseif entrust.dealVolume > 0 && entrust.dealVolume < entrust.volume && entrust.cancelVolume == 0
            fprintf('报单编号 %s 状态：部分成交\n',num2str(entrust.entrustNo));
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





