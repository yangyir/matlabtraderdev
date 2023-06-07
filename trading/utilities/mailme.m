function mailme(subject,message,attachments)

mail = '179024809@qq.com';  
password = 'rntrcnmookysbgjb';
receiver = 'yiran.yang@outlook.com';
%
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server','smtp.qq.com'); 
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
%
if nargin < 3
    sendmail(receiver,subject,message);
else
    sendmail(receiver,subject,message,attachments);
end

end

