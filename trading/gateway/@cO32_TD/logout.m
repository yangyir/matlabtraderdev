function [  ] = logout( self )
%LOGOUT �ǳ��ĺ���
% --------------------------
% �̸գ�20160201

% �����̨�Ѿ���¼
if self.is_Counter_Login
    Logout( self.connection , self.token );
    delete( self.heartbeatTimer );
    % ��˲��ٽ��е�¼( ����Ϊfalse )
    self.is_Counter_Login = false;
end

end

