function isc=analyze_ISC_parfor_srvr01(params,out_dataDir,condName,real_dataMat,Nshuf)

% create the group averages data mat
avgDataName=[condName '_avgData'];
corrmatName= [condName '_corrMAT'];
if nargin < 5 %%real data
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
else %%shuf data
    
    real_dataMat = permute(real_dataMat,[2 1 3]);
    [NTR,Nsubjs,Nvxls] = size(real_dataMat);
    %     null_isc = zeros(Nsubjs,Nvxls,Nshuf);
    %         parfor (n=1:Nshuf,5)
    for n=1:Nshuf
        c_name=[condName '_shuf' num2str(n)];
        if ~exist(fullfile(out_dataDir,[c_name '_corrMAT.mat']))
            shuf_data = phase_shuf_group_data(real_dataMat);
            shuf_data = permute(shuf_data,[2 1 3]);
            real_data = permute(real_dataMat,[2 1 3]);
            avgName = [avgDataName '_shuf' num2str(n)];
            shuf_allSub_avgs=create_AVG_data(out_dataDir,shuf_data,avgName,params.subjects);
            %             disp(['analyzing shuf ' num2str(n)]);
            calc_ISC_parfor(out_dataDir,real_data,shuf_allSub_avgs,c_name,params.subjects);
            %             null_isc(:,:,n)=shuf_isc;
            clear shuf_data
        end
        disp(['SHUF ' num2str(n) ' is DONE'])
    end
    
    if ~exist(fullfile(out_dataDir,['shuf_' condName '_corrMAT.mat']))
        %% load all shufs
        %         shuf_isc=null_isc;
        %         subjs=params.subjects;
        %         if ~exist(fullfile(out_dataDir))
        %             mkdir(fullfile(out_dataDir))
        %         end
        %         save(fullfile(out_dataDir,['shuf_' corrmatName '.mat']),'shuf_isc','subjs','-v7.3')
    end
end
end
