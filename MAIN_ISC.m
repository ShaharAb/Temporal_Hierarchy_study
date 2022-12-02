%% for final group analysis go to:  MAIN_ISC_TRW_juelich

%% 
clear all
close all

addpath('/home/hezi/shahara/niiTool')
params.dataDir=fullfile(pwd,'subjs_data');
d=dir(fullfile(params.dataDir,'sub*'));
params.subjects={d.name};
params.subjects=params.subjects([2,3,5:25 28]);
params.numOfRuns=5;
params.group_outData_dir = fullfile(params.dataDir,'Group_data');

%% get group conjuction vxls map
mask_name='group_stand_mask_MNI_newScales_24N.nii.gz';
% create_group_standmask(params.dataDir,params.subjects,mask_name)
params.g_mask=fullfile(params.dataDir,mask_name);

WHB_mask= fullfile(params.dataDir,mask_name);
mask = niftiread(WHB_mask);
niiInfo=niftiinfo(WHB_mask);
[linearidx, locations]  = getLocationsFromMaskNii(mask);


%% analyze experimantal data
%% First level
for s=1:length(params.subjects)
    params=setAnalysisParams_ISC(params.subjects{s},params);%load parameters
    for run=2:params.numOfRuns
        
        %register func to MNI
        outvol=fullfile(params.sub_funcMNI,['func_MNI_run' num2str(run) '.nii.gz']);
        if ~exist(outvol)
            reg_MNI_ISC(params,run,outvol)
        end
        
        %conjunct sub's MNI map with mask
        outMap=fullfile(params.sub_WHB_dir ,['WHB_funcData_run' num2str(run) '.nii.gz']);
        if ~exist(params.sub_WHB_dir )
            mkdir(params.sub_WHB_dir )
        end
        if ~exist(outMap)
            conjct_ROI(WHB_mask,run,outMap,params)
        end
        
        sub_run_mat_path=fullfile(params.sub_WHB_dir ,[params.subjects{s} '_run' num2str(run) '_data.mat']);
        if ~exist(sub_run_mat_path)
            
            conj_mat=niftiread(outMap);
            sub_run_mat=[];
            for t=1:size(conj_mat,4)
                t_mat=squeeze(conj_mat(:,:,:,t));
                sub_run_mat=[sub_run_mat; t_mat(linearidx)];% get signal only from voxels in the mask for each time point
            end
            
            %         Nan_ind= find(sub_run_mat(isnan(sub_run_mat)));
            %         low_ind= find(sub_run_mat<3000);
            
            %save the subject's run data within the mask
            save(fullfile(params.sub_WHB_dir ,[params.subjects{s} '_run' num2str(run) '_data.mat']),'sub_run_mat')
        end
        
    end
end

%% Group Level
out_real_dataDir=params.group_WHB_res_dir ;
if ~exist(out_real_dataDir)
    mkdir(out_real_dataDir)
end
conds={'01_intact','02_HG','03_SG','04_primitives'};

if ~exist (fullfile(out_real_dataDir,'CAKE_data.mat'))
    % save all subj data acording to conditions : #1 intact, #2 HG -high goals,
    % #3 SG -sub goals, #4 primitives
    CAKE_data=zeros(params.numOfRuns-1,length(params.subjects),325,length(linearidx)); % (#experimental conds,#subjects, #TR, #vxls in MNS ROI)
    all_c_order=[];
    for s=1:length(params.subjects)
        params=setAnalysisParams_ISC(params.subjects{s},params);%load parameters
       
        %get all exp conds data 
        load(fullfile(params.logFolder,'log.mat'))
        c_order=log.condOrder;
        all_c_order=[all_c_order;c_order];
        for c=1:params.numOfRuns-1
            c_run=find(c_order==c)+1;
            load(fullfile(params.sub_WHB_dir ,[params.subjects{s} '_run' num2str(c_run) '_data.mat']))
            CAKE_data(c,s,:,:)=sub_run_mat;
        end
    end
    
    
    % start analyzing from 5th TR after first until the 5th TR after the end of the movie (into fixation)
    % localizer_data=localizer_data(:,17:349,:);
    %     CAKE_data=CAKE_data(:,:,17:365,:);%pilot-old stimuli
    CAKE_data=CAKE_data(:,:,17:318,:);
    subjs=params.subjects;
    save(fullfile(out_real_dataDir,'CAKE_data.mat'),'CAKE_data','subjs','conds','-v7.3')
end

%%  Inter-SC
load(fullfile(out_real_dataDir,'CAKE_data.mat'));


%% for experimental conditions --  analyze ISC on real data per vxls

for c=1:length(conds)
    % ISC
    condName=conds{c};
    RealdataMat=squeeze(CAKE_data(c,:,:,:));
    analyze_ISC(params,out_real_dataDir,condName,RealdataMat);
    
    % convert ISC to map
    outDir= fullfile(pwd,'subjs_data','Group_corr_maps','WHB_maps');
    if ~exist(fullfile(outDir,['WHB_' conds{c} '.nii']))
        if ~exist(outDir)
            mkdir(outDir)
        end
        
        load(fullfile(out_real_dataDir,[conds{c} '_corrMAT.mat']));
        corrvox=mean(isc); %averaged ISC across subjects
        mapName = ['WHB_' conds{c}];
        create_ISC_MAPS(outDir,linearidx,mask,niiInfo,corrvox,mapName)
    end
end

%% shuffle data to get ISC threshold
cond_data=squeeze(CAKE_data(1,:,:,:));
condName=conds{1};
create_nul_dist_cakeData(params, cond_data, condName)

%% create mask for the trw analysis based on shufle data
gen_intact_sigMap_Juelich() % calc pval based on shufle of intact data and generate map
