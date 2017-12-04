%
pathhome = getenv('HOME');
cd(pathhome);
%
if exist('c_opt1','var') && isa(c_opt1,'CounterCTP') && c_opt1.is_Counter_Login
    c_opt1.logout;
end
if exist('m_opt1','var') && isa(m_opt1,'cCTP') && m_opt1.isconnect
    m_opt1.logoff;
end
%
%
if exist('c_opt2','var') && isa(c_opt2,'CounterCTP') && c_opt2.is_Counter_Login
    c_opt2.logout;
end
if exist('m_opt2','var') && isa(m_opt2,'cCTP') && m_opt2.isconnect
    m_opt2.logoff;
end
%
%
if exist('c_fut','var') && isa(c_fut,'CounterCTP') && c_fut.is_Counter_Login
    c_fut.logout;
end
if exist('m_fut','var') && isa(m_fut,'cCTP') && m_fut.isconnect
    m_fut.logoff;
end

