%%
% init qms for replay. as we know that we only use the local '.txt' file
% for replay
if ~(exist('qms_replay','var') && isa(qms_replay,'cQMS'))
    qms_replay = cQMS;
    qms_replay.setdatasource('local');
end