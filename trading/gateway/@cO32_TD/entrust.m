function [errorCode,errorMsg,entrustNo] = entrust(self, marketNo,stockCode,entrustDirection,entrustPrice,entrustAmount)
%ENTRUST ��CounterHSO32�����°�װEntrust����
%[errorCode,errorMsg,entrustNo] = entrust(marketNo, stockCode, entrustDirection, entrustPrice, entrustAmount)
% --------------------------
% �̸գ�20160201


connection  = self.connection;
token       = self.token;
accountCode = self.accountCode;
combiNo     = self.combiNo;

[errorCode,errorMsg,entrustNo] = PlaceEntrust(connection,token,combiNo,marketNo,stockCode,entrustDirection,entrustPrice,entrustAmount);



end

