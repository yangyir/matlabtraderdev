function [errorCode,errorMsg,entrustNo] = futPlaceEntrust(self, marketNo,stockCode,entrustDirection, futureDirection,entrustPrice,entrustAmount)
%futPlaceEntrust 在CounterHSO32中重新包装PlaceFutEntrust函数
%[errorCode,errorMsg,entrustNo] = futPlaceEntrust(self,marketNo, stockCode, entrustDirection, futureDirection, entrustPrice, entrustAmount)
% 注：futureDirection开平方向
% --------------------------
% 朱江，20160316

%% main
connection  = self.connection;
token       = self.token;
accountCode = self.accountCode;
combiNo     = self.combiNo;

[errorCode,errorMsg,entrustNo] = PlaceFutEntrust(connection,token,combiNo,marketNo,stockCode,entrustDirection,futureDirection, entrustPrice,entrustAmount);



end

