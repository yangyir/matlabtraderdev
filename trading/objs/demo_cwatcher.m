clc;
fprintf('demo_cwatcher.m\n');
w = cWatcher;

%test of member function 'addsingle'
single = 'cu1801';
w.addsingle(single);
nsingle = w.countsingles;
if nsingle ~= 1
    error('internal error:check required!')
end

%test of member function 'addsingles'
singles = 'al1801,zn1801,pb1801,ni1801,ag1712,au1712';
w.addsingles(singles);
nsingle = w.countsingles;
if nsingle ~= 7
    error('internal error:check required!')
end

%test of member function 'addpair'
pair = 'tf1706,t1706';
w.addpair(pair);
nsingle = w.countsingles;
if nsingle ~= 9
    error('internal error:number of singles are not equal to 9 as expected!')
end
npairs = w.countpairs;
if npairs ~= 1
    error('internal error:number of pairs are not equal to 1 as expected!')
end

%test of member function 'addpairs'
pairs = 'tf1709,t1709;tf1712,t1712';
w.addpairs(pairs);
nsingle = w.countsingles;
if nsingle ~= 13
    error('internal error:number of singles are not equal to 13 as expected!')
end
npairs = w.countpairs;
if npairs ~= 3
    error('internal error:number of pairs are not equal to 3 as expected!')
end

%test of member function 'removesingle'
w.removesingle('ag1712');
nsingle = w.countsingles;
if nsingle ~= 12
    error('internal error:number of singles are not equal to 12 as expected!')
end

%test of member function 'removesingles'
singles = 'ag1712,au1712';
%here 'ag1712' has been removed already and a warning message shall be
%poped up
w.removesingles(singles);
nsingle = w.countsingles;
if nsingle ~= 11
    error('internal error:number of singles are not equal to 11 as expected!')
end

%test of member function 'removepair'
w.removepair('tf1706,t1706');
npairs = w.countpairs;
if npairs ~= 2
    error('internal error:number of pairs are not equal to 2 as expected!')
end
% 
pairs = 'tf1706,t1706;tf1709,t1709';
%here 'tf1706,t1706' has been removed already and a warning message shall be
%poped up
w.removepairs(pairs);
nsingle = w.countsingles;
if nsingle ~= 7
    error('internal error:number of singles are not equal to 7 as expected!')
end
npairs = w.countpairs;
if npairs ~= 1
    error('internal error:number of pairs are not equal to 1 as expected!')
end

%test of member function 'addstruct'
structstr = 'rb1801,i1801,j1801';
weights = [1;-1.6;-0.41];
w.addstruct(structstr,weights);
%add another struct
structstr = 'a1801,m1801,y1801';
w.addstruct(structstr,weights);

%test of member function 'removestruct'
w.removestruct(structstr);

w.addsingle('m1801-C-2700');

w.conn = 'bloomberg';
% w.conn = 'wind';
w.refresh;
quotes_single = w.qs;
for i = 1:size(quotes_single,1)
    quotes_single{i}.print;
end

quotes_pair = w.qp;
for i = 1:size(quotes_pair,1)
    quotes_pair{i}.print;
end


% w.close;


fprintf('test done,all passed\n')




