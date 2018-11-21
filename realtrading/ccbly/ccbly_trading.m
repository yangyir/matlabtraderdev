%% counter login
cd(ccbly_path_manual);
ccbly_counter = ccbly.ops.getcounter;
if ~ccbly_counter.is_Counter_Login, ccbly_counter.login; end