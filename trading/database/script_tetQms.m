
mktlogout;
clear all; 
qms_ = QMS_Fusion;

opt_fn = 'D:\Github\matlabtraderdev\trading\database\@cQMS_H5\ContractInfo\OptInfo_new.xlsx';
fut_fn = 'D:\Github\matlabtraderdev\trading\database\@cQMS_H5\ContractInfo\FutureInfo.xlsx';
stk_fn = 'D:\Github\matlabtraderdev\trading\database\@cQMS_H5\ContractInfo\StockInfo.xlsx';

% qms_.loginCTP();
qms_.loginH5TestEnv();
qms_.init(opt_fn, fut_fn, stk_fn);

%qms_.logout()