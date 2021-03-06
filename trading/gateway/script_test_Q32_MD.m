%% cQMS_H5
% 登入连接行情服务器，返回为1时表示登录成功
% mktlogin
% pause(5)

% [mkt, level] = getCurrentPrice(code,marketNo);
% marketNo: 上海证券交易所='1';深交所='2'; 上交所期权='3';中金所='5'
% mkt: 5*1数值向量, 依次为最新价,成交量,交易状态(=0表示取到行情;=1表示未取到行情),交易分钟数,秒钟数
% marketNo: 0 -上海L1,深圳L1,转上市地，新三板 1
% level: 盘口数据(5*4矩阵), 第1~4列依次为委买价,委买量,委卖价,委卖量

mktlogout;
clear all; 
qms_ = cQMS_H5;

opt_fn = 'D:\Github\matlabtraderdev\trading\database\@cQMS_H5\ContractInfo\OptInfo_latest.xlsx';
fut_fn = 'D:\Github\matlabtraderdev\trading\database\@cQMS_H5\ContractInfo\FutureInfo.xlsx';
stk_fn = 'D:\Github\matlabtraderdev\trading\database\@cQMS_H5\ContractInfo\StockInfo.xlsx';

% qms_.loginCTP();
qms_.loginTestEnv();

%[mkt,level] = getCurrentPrice(num2str('TF1812'),'5')
qms_.init(opt_fn, fut_fn, stk_fn);

%qms_.logoff()
%% demo
% 
% % 登入连接行情服务器，返回为1时表示登录成功
% mktlogin
% pause(2);
% while 1
%     lastP = getCurrentPrice('510050','1');
%     disp(['code: 510050, price: ', num2str(lastP)]);
% %     lastP = getCurrentPrice('000001','2');
% %     disp(['code: 000001, price: ', num2str(lastP)]);
%     pause(2);
% end
% 
% % 退出行情服务器连接
% mktlogout


%% QMS_fusion
mktlogout;
clear all; 
qms_ = QMS_Fusion;

opt_fn = 'D:\Github\matlabtraderdev\trading\database\@cQMS_H5\ContractInfo\OptInfo_latest.xlsx';
fut_fn = 'D:\Github\matlabtraderdev\trading\database\@cQMS_H5\ContractInfo\FutureInfo.xlsx';
stk_fn = 'D:\Github\matlabtraderdev\trading\database\@cQMS_H5\ContractInfo\StockInfo.xlsx';

% qms_.loginCTP();
qms_.loginH5TestEnv();
qms_.init(opt_fn, fut_fn, stk_fn);
%[mkt,level] = getCurrentPrice(num2str('TF1812'),'5')
%qms_.logout()
% % 

