cd([getenv('HOME'),'regressiontest\ctpcounter\']);

front_addr_ = 'tcp://116.236.253.145:42213';
broker_id_ = '95533';
investor_id_ = '52013132';
investor_password_ = '2011Sep29';

[ret,id] = mdlogin(front_addr_, broker_id_, investor_id_, investor_password_);
%%
if ret
    loop = 100;
    while(loop>0)
        [mkt, level, update_time] = getoptquote(1,'cu1908');
        fprintf('update time:%s\n',update_time);
        loop = loop -1;
    end
    pause(10);

    mdlogout(id);
else
    disp('login failed');
end
