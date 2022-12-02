function isc=analyze_ISC(params,out_dataDir,condName,real_dataMat)

% create the group averages data mat
avgDataName=[condName '_avgData'];
corrmatName= [condName '_corrMAT'];
% if nargin < 5 %%real data
    ran_real_AVG_data = exist(fullfile(out_dataDir,[avgDataName '.mat']));
    ran_real_ISC = exist(fullfile(out_dataDir,[corrmatName '.mat']));
    
    if ~ran_real_ISC
        if ~ran_real_AVG_data
            allSub_avgs=create_AVG_data(out_dataDir,real_dataMat,avgDataName,params.subjects);
        else
            load(fullfile(out_dataDir,[condName '_avgData.mat']));
        end
        % calc Inter-SC
        isc=calc_ISC(out_dataDir,real_dataMat,allSub_avgs,condName,params.subjects);
    end
end