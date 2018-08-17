function [  ] = logout( self )
%LOGOUT 登出的函数
% --------------------------
% 程刚，20160201

% 如果柜台已经登录
if self.is_Counter_Login
    Logout( self.connection , self.token );
    delete( self.heartbeatTimer );
    % 因此不再进行登录( 设置为false )
    self.is_Counter_Login = false;
end

end

