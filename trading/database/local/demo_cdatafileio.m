fprintf('demo_cdatafileio\n');

a = what;
directory_ = a.path;
if ~strcmpi(directory_(end),'\'), directory_ = [directory_,'\']; end

fn = 'demo_cdatafileio_testfile.txt';
fullfn = [directory_,fn];

%% create random data in matlab first
coldefs = {'datetime','trade','bid','ask'};
datestart = now;
nrows = 100;
ncols = 4;
data = zeros(nrows,ncols);
data(1,1) = datestart;
data(1,2) = 100;
data(1,3) = 99.995;
data(1,4) = 100;
for i = 2:nrows
    data(i,1) = datestart + (i-1)/1440;
    data(i,2) = data(i-1,2)*exp(randn*0.3*(i-1)/1440/252);
    data(i,3) = data(i,2);
    data(i,4) = data(i,3) + 0.005;
end

%% save data into '.txt' file
fid = fopen(fullfn,'w');
formatstr = '%s\t%s\t%s\t%s\n';
fprintf(fid,formatstr,coldefs{1},coldefs{2},coldefs{3},coldefs{4});

formatstr = '%f\t%f\t%f\t%f\n';
for i = 1:nrows
    fprintf(fid,formatstr,data(i,1),data(i,2),data(i,3),data(i,4));
end

fclose(fid);

%% load data from '.txt' file
% create a copy of fn in the current folder
fncopy = ['copy_',fn];
copyfile(fullfn,fncopy);
% load data from the copied file
A = importdata(fncopy);
flds = fields(A);
data_loaded = A.(flds{1});
coldefs_loaded = A.(flds{3});

%% save data into '.xlxs' file

xlswrite([directory_,'example.xlsx'], [coldefs,data]);

%% load data from excel file
num = xlsread([directory_,'example.xlsx']);
%%
p = rand(1,10);
q = ones(10);
save('pqfile.txt','p','q','-ascii')
type('pqfile.txt')
%%
save('data.txt','data','-ascii');