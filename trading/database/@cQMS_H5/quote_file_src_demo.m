function [] = quote_file_src_demo
    delete(timerfindall);
    clear all; rehash;
    
    cloud_doc_dir = 'C:\Users\Rick Zhu\Documents\Synology Cloud';
%     cloud_doc_dir = 'D:';
fn = '\intern\7.�콭\l2�ο�cg\��Ȩ��ʷ��Ϣ\OptInfo20160328.xlsx';
opt_fn = [cloud_doc_dir, fn];

fut_fn = [cloud_doc_dir, '\intern\optionClass\FutureInfo.xlsx'];
stk_fn = [cloud_doc_dir, '\intern\optionClass\StockInfo.xlsx'];

opt_src = [cloud_doc_dir, '\intern\7.�콭\l2�ο�cg\���ŷָ���Ȩ��������\SH20160328.out_9002'];
stk_src = [cloud_doc_dir, '\intern\7.�콭\l2�ο�cg\\50ETF\SH20150625.out_510050_3202'];

qms_ = QMS;
qms_.init_src_from_file(opt_fn, stk_fn, fut_fn, opt_src, stk_src);
% qms_.init_test(opt_fn, fut_fn, stk_fn);
end