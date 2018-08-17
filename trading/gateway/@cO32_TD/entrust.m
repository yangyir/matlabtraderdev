function [errorCode,errorMsg,entrustNo] = entrust(self, marketNo,stockCode,entrustDirection,entrustPrice,entrustAmount)
%ENTRUST 在CounterHSO32中重新包装Entrust函数
%[errorCode,errorMsg,entrustNo] = entrust(marketNo, stockCode, entrustDirection, entrustPrice, entrustAmount)
% --------------------------
% 程刚，20160201


connection  = self.connection;
token       = self.token;
accountCode = self.accountCode;
combiNo     = self.combiNo;

[errorCode,errorMsg,entrustNo] = PlaceEntrust(connection,token,combiNo,marketNo,stockCode,entrustDirection,entrustPrice,entrustAmount);



end

