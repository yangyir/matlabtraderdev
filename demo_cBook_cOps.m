%demo
login_counter_fut;
%%
book = cBook;
book.init('fut1','yiran',c_fut);
book.loadpositionsfromcounter('futlist','all');
book.printpositions;
%%
ops = cOps;
ops.init('yiran_ops',book);
%%
init_mde;
%%
codes = {'ni1807';'rb1810'};
secs = cell(size(codes));
for i = 1:size(codes,1)
    secs{i} = cFutures(codes{i});secs{i}.loadinfo([codes{i},'_info.txt']);
    mdefut.registerinstrument(secs{i});
end
mdefut.refresh
%%
pnl = ops.calcrunningpnl('code','ni1807','MDEFut',mdefut);
fprintf('pnl of ni1807:%s\n',num2str(pnl));
pnl = ops.calcrunningpnl('code','rb1810','MDEFut',mdefut);
fprintf('pnl of rb1810:%s\n',num2str(pnl));
pnl = ops.calcrunningpnl('MDEFut',mdefut);
fprintf('pnl of book:%s\n',num2str(sum(pnl)));
%%
ops.printrunningpnl('MDEFut',mdefut);





