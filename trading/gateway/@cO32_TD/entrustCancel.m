function [errorCode, errorMsg,cancelNo] = entrustCancel(self, entrustNo)
%ENTRUSTCANCEL ��CounterHSO32�����°�װ����EntrustsCancel
% --------------------------
% �̸գ�20160201

connection  = self.connection;
token       = self.token;
accountCode = self.accountCode;
combiNo     = self.combiNo;

[errorCode, errorMsg,cancelNo] = EntrustCancel( connection,token,combiNo,entrustNo, 1);
end
