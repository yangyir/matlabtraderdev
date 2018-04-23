login_counter_fut;
login_counter_opt1;
login_counter_opt2;
%%
% Here 5 books are created, i.e.
% Book1: positions of futures in counter c_fut
% Book2: positions of futures in counter c_opt1
% Book3: positions of options in counter c_opt1
% Book4: positions of futures in counter c_opt2
% Book5: positions of options in counter c_opt2
% initiate trading books
b1 = cBook;b1.init('Book1','yiran',c_fut);
b2 = cBook;b2.init('Book2','yiran',c_opt1);
b3 = cBook;b3.init('Book3','yiran',c_opt1);
b4 = cBook;b4.init('Book4','yiran',c_opt2);
b5 = cBook;b5.init('Book5','yiran',c_opt2);
%%
b1.loadpositionsfromcounter;
b2.loadpositionsfromcounter('futlist','all');
b3.loadpositionsfromcounter('optundlist','all');
b4.loadpositionsfromcounter('futlist','all');
b5.loadpositionsfromcounter('optundlist','all');
%
b1.printpositions;
b2.printpositions;
b3.printpositions;
b4.printpositions;
b5.printpositions;
%%
cobdate = getlastbusinessdate;
folder = [getenv('OneDrive'),'\bookinfo\'];
fn1 = ['book1_',datestr(cobdate,'yyyymmdd'),'.txt'];
fn2 = ['book2_',datestr(cobdate,'yyyymmdd'),'.txt'];
fn3 = ['book3_',datestr(cobdate,'yyyymmdd'),'.txt'];
fn4 = ['book4_',datestr(cobdate,'yyyymmdd'),'.txt'];
fn5 = ['book5_',datestr(cobdate,'yyyymmdd'),'.txt'];
if ~b1.isemptybook, b1.savepositionstofile([folder,fn1]); end
if ~b2.isemptybook, b2.savepositionstofile([folder,fn2]); end
if ~b3.isemptybook, b3.savepositionstofile([folder,fn3]); end
if ~b4.isemptybook, b4.savepositionstofile([folder,fn4]); end
if ~b5.isemptybook, b5.savepositionstofile([folder,fn5]); end
%%
b1.loadpositionsfromfile([folder,fn1],cobdate);
b2.loadpositionsfromfile([folder,fn2],cobdate);
b3.loadpositionsfromfile([folder,fn3],cobdate);
b4.loadpositionsfromfile([folder,fn4],cobdate);
b5.loadpositionsfromfile([folder,fn5],cobdate);
%
b1.printpositions;
b2.printpositions;
b3.printpositions;
b4.printpositions;
b5.printpositions;




