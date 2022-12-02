function gen_intact_sigMap_Juelich()

main_out  = fullfile(pwd, 'subjs_data/Group_data/intact_in_juelich');
if ~exist(main_out)
    mkdir(main_out)
end
%compare real data to null_dist (to generate Pvalue) in voxels within the group mask and the juelich atlas

real_data = load(fullfile(pwd, 'subjs_data/Group_data/WHB_res/01_intact_CORMAT_w_linind.mat'));
group_isc= mean(real_data.isc,1);

stand = fullfile(pwd, 'subjs_data/group_stand_mask_MNI_newScales_24N.nii.gz');
stand_mask = niftiread(stand);
niiInfo=niftiinfo(stand);

%% get shufs data
shufs_dir = fullfile(pwd, 'subjs_data/Group_data/WHB_res/shuf_01_intact');
shufs = dir(fullfile(shufs_dir, '*.mat'));
shuf_names = {shufs(:).name};

shuf_mat = zeros(length(shufs), length(group_isc));
for s = 1:length(shufs)
    s_data = load(fullfile(shufs_dir, shuf_names{s}), 'isc');
    shuf_mat(s , :) = mean(s_data.isc, 1);
end

%% calc 'raw' pvals
pvals = zeros(size(group_isc));
for v=1:length(pvals)
    v_real = group_isc(v);
    if v_real > 0
        v_shuf = shuf_mat(:,v);
        n_real_below = sum(v_real<=v_shuf);
        p_val = n_real_below/numel(v_shuf);
        if p_val == 0
            pvals(v) = 1/numel(v_shuf);
        else
            pvals(v) = p_val;
        end
    end
end

intact_pvals = zeros(size(stand_mask));
intact_pvals(real_data.linearidx) = pvals; %all p values
intact_pvals_map = fullfile(main_out, 'intact_pvals_map.nii');
niftiwrite(single(intact_pvals),intact_pvals_map,niiInfo)

% cmd= ['fdr -i ' intact_pvals_map ' -m '  stand ' -q 0.01'];


%% create group mask in the standard and juelich mask

juelich = fullfile(main_out, 'Juelich-maxprob-thr0-2mm.nii.gz');
juelich_mask = double(niftiread(juelich));

jl_stand_mask = juelich_mask .* double(stand_mask);
jl_stand_mask(jl_stand_mask>0)=1;

jl_stand_mask_path = fullfile(main_out, 'Juelich_stand_mask.nii');
niftiwrite(single(jl_stand_mask),jl_stand_mask_path,niiInfo)

intact_jl_stand_mask_pvals = intact_pvals .* jl_stand_mask;  % pvals only in group-juelich mask
% outfile = fullfile(pwd,...
%     'subjs_data/Group_data/intactq001_in_juelich200_res/valid/intact_schf_stand_mask_pvals.nii');
outfile = fullfile(main_out, 'intact_juelich_stand_mask_pvals.nii');
niftiwrite(single(intact_jl_stand_mask_pvals),outfile,niiInfo)

% fdr correction for voxls in mask
%run this in terminal to get threshold
cmd= ['fdr -i ' outfile ' -m ' jl_stand_mask_path ' -q 0.01'];

thresh = 0.006; %after running cmd in terminal
sig_intact_jl_stand_mask_pvals = intact_jl_stand_mask_pvals;
sig_intact_jl_stand_mask_pvals(intact_jl_stand_mask_pvals>thresh) = 0;

sig_intact_mask = sig_intact_jl_stand_mask_pvals;
sig_intact_mask(sig_intact_jl_stand_mask_pvals>0)=1; % binarize sig pvalues

% sig_map = fullfile(pwd,...
%     'subjs_data/Group_data/intactq001_in_juelich200_res/valid/sig_intact_schf200_stand_mask_q01.nii');

sig_map = fullfile(main_out, 'sig_intact_juelich_stand_mask_q01.nii');
niftiwrite(single(sig_intact_mask),sig_map,niiInfo)

% get juelich only in final mask
juelich_lbls_in_fin_mask = sig_intact_mask.*juelich_mask;

juelich_in_mask_map = fullfile(main_out, 'juelich_lbls_in_fin_mask.nii');
niftiwrite(single(juelich_lbls_in_fin_mask),juelich_in_mask_map,niiInfo)
end


















