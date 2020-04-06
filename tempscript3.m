ifut = 7;
op = outputs{5,ifut};
p = op.p;
bs = op.bs;ss = op.ss;bc = op.bc;sc = op.sc;lvlup = op.lvlup;lvldn = op.lvldn;

%
idx2check = find(bs==9);
tags = cell(length(idx2check),2);
for i = 1:length(idx2check)
    j = idx2check(i);
    tags{i,1} = j;
    tags{i,2} = tdsq_lastbs2(bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),bc(1:j),sc(1:j),p(1:j,:));
end
open tags
%%
i=1;
tdsq_plot2(p,idx2check(i)-8,min(idx2check(i)+24,size(p,1)),code2instrument(codes{ifut}));
%%
nfut = size(outputs,2);
tags = cell(nfut,1);
for ifut = 1:nfut
    futname = codes{ifut};
    op = outputs{5,ifut};
    p = op.p;
    bs = op.bs;ss = op.ss;bc = op.bc;sc = op.sc;lvlup = op.lvlup;lvldn = op.lvldn;
    idx2check = find(bs==9);
    tags_i = cell(length(idx2check),2);
    for i = 1:length(idx2check)
        j = idx2check(i);
        tags_i{i,1} = j;
        tags_i{i,2} = tdsq_lastbs2(bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),bc(1:j),sc(1:j),p(1:j,:));
    end
    tags{ifut} = tags_i;
end
%% perfect case
nperfect = 0;
for ifut = 1:nfut
    for j = 1:length(tags{ifut})
        if (isempty(strfind(tags{ifut}{j,2},'imperfectbs')) && isempty(strfind(tags{ifut}{j,2},'semiperfectbs')))
            nperfect = nperfect+1;
        end
    end
end

    