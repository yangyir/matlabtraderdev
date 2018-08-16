function [] = demo()
% QMS demo 
delete(timerfindall);
mdlogout;
clear all; rehash;

cloud_doc_dir = 'C:\Users\Rick Zhu\Documents\Synology Cloud';
% cloud_doc_dir = 'D:';
fn = '\intern\7.÷ÏΩ≠\test_opt_info.xlsx';
file_path = [cloud_doc_dir, fn];

fut_fn = [cloud_doc_dir, '\intern\optionClass\FutureInfo.xlsx'];
stk_fn = [cloud_doc_dir, '\intern\optionClass\StockInfo.xlsx'];

qms_ = QMS_Fusion;
qms_.init(file_path, fut_fn, stk_fn);

pause(30);

vs = qms_.impvol_surface_;
% vs.plot();

% pause(100);

% qms_.release();

end