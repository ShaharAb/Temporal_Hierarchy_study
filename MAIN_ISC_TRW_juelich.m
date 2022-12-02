main_out  = fullfile(pwd, 'subjs_data/Group_data/intact_in_juelich');

%% generate the data structure according to rois in rois_mask

params.dataDir=fullfile(pwd,'subjs_data');
d=dir(fullfile(params.dataDir,'sub*'));
subjs={d.name};
subjs=subjs([2,3,5:25 28]);
conds={'01_intact','02_HG','03_SG','04_primitives'};
WHB_mask= fullfile(pwd, 'subjs_data/group_stand_mask_MNI_newScales_24N.nii.gz');
mask = niftiread(WHB_mask);
niiInfo=niftiinfo(WHB_mask);
[linearidx, locations]  = getLocationsFromMaskNii(mask);

rois_mask= fullfile(main_out, 'juelich_lbls_in_fin_mask.nii');

mat_name = 'cake_juel_roi_data';
if ~exist(fullfile(main_out,[mat_name '.mat']))
    load(fullfile(pwd, 'subjs_data/Group_data/WHB_res/CAKE_data.mat'));
    [cake_roi_data,rois_size,roi_lbls]=create_data_in_juelrois(CAKE_data,linearidx,rois_mask);
    save(fullfile(main_out,[mat_name '.mat']),...
        'cake_roi_data','subjs','conds','rois_size','roi_lbls','rois_mask','-v7.3')
else
    load(fullfile(main_out,[mat_name '.mat']))
end

%ISC
params.subjects = subjs;
for c=1:length(conds)
    condName=conds{c};
    RealroiData=squeeze(cake_roi_data(c,:,:,:));
    analyze_ISC(params,main_out,condName,RealroiData);
end

%% create ROIs ISC map in mask
create_rois_isc_map()
%% compare isc between conditions to find trws
% compare data within Juelich rois only in the significant intact vxls q=0.01
lbls_file =fullfile(main_out, 'juelich_lbls.xls');
fout=fullfile(main_out,'trw_juelich_in_sig_intact');
compare_in_juelrois(rois_mask,main_out,lbls_file,fout,mat_name) %based on averaged raw signal in roiel per subject





