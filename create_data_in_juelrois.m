function [cake_roi_data,rois_size,roi_lbls]=create_data_in_juelrois(CAKE_data,linearidx,map)


atlas = double(niftiread(map));

flat_atlas = atlas(linearidx);
roi_lbls = unique(flat_atlas);
roi_lbls = roi_lbls(2:end);

cake_roi_data=zeros(size(CAKE_data,1),size(CAKE_data,2),size(CAKE_data,3),length(roi_lbls));
rois_size=zeros(size(roi_lbls))';

for lbl=1:length(roi_lbls)
    roi_inds = find(flat_atlas==roi_lbls(lbl));
    n_vxls = length(roi_inds);
    
    % calculate the mean signal acroos voxels in roi per each
    % subject in each condition
    roi_data=CAKE_data(:,:,:,roi_inds);
    m_roi_data=squeeze(mean(roi_data,4));
    cake_roi_data(:,:,:,lbl)=m_roi_data;
    rois_size(lbl)=n_vxls;   
end
end



