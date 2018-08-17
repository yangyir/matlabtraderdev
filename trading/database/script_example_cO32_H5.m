%% example : How to use cO32_H5
clear all ;
qms_ = cO32_H5();
qms_.login('test');
pause(5);%wait respond
instruments = cStock('510050');
while (true)
    data = qms_.realtime(instruments,'');
    disp(['code: ',instruments.code_H5,' lastPrice ',num2str(data{1}.mkt(1,1)), ' level: ', num2str(length(data{1}.level))]);
    pause(1);
end
qms_.logout();


%qms_.init(qms_.test_env_dir);