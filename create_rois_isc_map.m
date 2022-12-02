function create_rois_isc_map()

data_dir = fullfile(pwd, 'subjs_data/Group_data/intact_in_juelich');
mask_lbls = niftiread(fullfile(data_dir,'juelich_lbls_in_fin_mask.nii'));
ul = unique(mask_lbls);
ul = ul(2:end);
rois_isc_mat = zeros(size(mask_lbls));
load(fullfile(data_dir, '01_intact_corrMAT.mat'));
intact_isc = mean(isc);

for l=1:length(ul)
    rois_isc_mat(mask_lbls==ul(l)) = intact_isc(l);
end
%write map
niiInfo=niftiinfo(fullfile(data_dir,'juelich_lbls_in_fin_mask.nii'));
niftiwrite(single(rois_isc_mat),...
    fullfile(data_dir,'intact_isc_in_juelich_lbls_fin_mask'),...
    niiInfo)

end