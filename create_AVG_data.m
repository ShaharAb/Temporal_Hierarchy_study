function allSub_avgs=create_AVG_data(G_dataDir,dataMat,avgDataName,subjs)

sumOfall= squeeze(sum(dataMat,1));

%create mat of group average for each subject
allSub_avgs = zeros(size(dataMat));

for s= 1:length(subjs)
    subj_data=squeeze(dataMat(s,:,:));
    sub_groupavg=(sumOfall-subj_data)/(length(subjs)-1); %group average without that subject
    allSub_avgs(s,:,:)=sub_groupavg;
end

if ~contains(G_dataDir,'shuf')
    name=[avgDataName '.mat'];
    save(fullfile(G_dataDir,[avgDataName '.mat']),'allSub_avgs','subjs','-v7.3')
end
end
