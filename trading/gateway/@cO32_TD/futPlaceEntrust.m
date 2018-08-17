function [errorCode,errorMsg,entrustNo] = futPlaceEntrust(self, marketNo,stockCode,entrustDirection, futureDirection,entrustPrice,entrustAmount)
%futPlaceEntrust ��CounterHSO32�����°�װPlaceFutEntrust����
%[errorCode,errorMsg,entrustNo] = futPlaceEntrust(self,marketNo, stockCode, entrustDirection, futureDirection, entrustPrice, entrustAmount)
% ע��futureDirection��ƽ����
% --------------------------
% �콭��20160316

%% main
connection  = self.connection;
token       = self.token;
accountCode = self.accountCode;
combiNo     = self.combiNo;

[errorCode,errorMsg,entrustNo] = PlaceFutEntrust(connection,token,combiNo,marketNo,stockCode,entrustDirection,futureDirection, entrustPrice,entrustAmount);



end

