qms = cQMS;
qms.setdatasource('bloomberg');
%%
code_ctp_underlier = 'SR805';
numstrikes = 7;

%%
[calls,puts,underlier] = getlistedoptions(code_ctp_underlier,numstrikes);

%%
ivslice = cVolSlice;
for i = 1:numstrikes
    ivslice.registeroption(calls{i});
    qms.registerinstrument(calls{i});
end

%%
ivslice.refresh(qms);
        
        