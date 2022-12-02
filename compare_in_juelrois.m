function compare_in_juelrois(atlas_map,isc_dir,lbls_file,fout,mat_name)

close all

load(fullfile(isc_dir,[mat_name '.mat']),'rois_size')


conds={'01_intact','02_HG','03_SG','04_primitives'};
for c=1:length(conds)
    load(fullfile(isc_dir, [conds{c} '_corrMAT.mat']))
    all_conds_isc(c,:,:)=isc;
    clear isc
end

T = readtable(lbls_file);
t=table2cell(T);
t_lbls =cell2mat(t(:,1));

atlas=niftiread(atlas_map);
niiInfo=niftiinfo(atlas_map);
atlas_roi_lbls = unique(atlas);
atlas_roi_lbls=atlas_roi_lbls(2:end);

types.VERY_LONG=[];
types.LONG=[];
types.INTERM=[];
types.SHORT=[];
types.WIERD=[];

final_rois=[];
rois_p_val=[];
final_r_info=[];
final_r_means=[];
final_r_SE=[];
rois_IvsP_t=[];
cnt=0;
small_rois = [];
for roi =1:length(rois_size)
    %get roi name from xls
    roi_lbl=atlas_roi_lbls(roi);
    roi_name=t{t_lbls==roi_lbl, 2};
    if (rois_size(roi)<30)
        r = [{roi_lbl}, roi_name];
        small_rois = [small_rois; r];
    else 
        cnt=cnt+1;
        roi_name = [num2str(roi_lbl) '_' roi_name];
        final_rois=[final_rois;{roi_name}];
        % compare conditions
        roi_isc=squeeze(all_conds_isc(:,:,roi));
        roi_c_means=mean(roi_isc,2);
        final_r_means=[final_r_means;roi_c_means'];
        
        roi_SE= std(roi_isc,0,2)/(sqrt(size(roi_isc,2)));
        final_r_SE=[final_r_SE;roi_SE'];
        
        [sigs, pvals, IvsP_t]=get_roi_stats_withT(roi_isc);
        rois_p_val=[rois_p_val;pvals];
        rois_IvsP_t = [rois_IvsP_t, IvsP_t];
        
        roi_info={roi_lbl, roi_name, rois_size(roi), cnt} ;
        final_r_info=[final_r_info;roi_info];
    end
end

%calc fdr on pvlas
% fout = [fout '_typq05'];
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(rois_p_val,0.05,'pdep','no');
sig_ps=h;

% create map of rois intact vs. prim t values
sig_IvsP = sig_ps(:,3);
tval_img = zeros(size(atlas));
for roi=1:length(final_rois)
        roi_lbl=final_r_info{roi,1};
    if sig_IvsP(roi)==1
       tval_img(atlas==roi_lbl)=rois_IvsP_t(roi);
    end
end
out_roi_tvals = fullfile(isc_dir,'rois_IvsP_t');
niftiwrite(single(tval_img),out_roi_tvals,niiInfo)


% gen list, types nifti map and plot final rois
type_img = zeros(size(atlas));
final_types = zeros(size(final_rois));
for roi=1:length(final_rois)
    roi_lbl=final_r_info{roi,1};
    roi_means= final_r_means(roi,:);
    sig_p=sig_ps (roi,:);
    SEs=final_r_SE(roi,:);

    type=get_roi_type_tailSig(sig_p);
    
    r_info=final_r_info(roi,:);
    r_size=r_info{3};
    roi_name=r_info{2};
    
    
    if strcmp(type,'Very Long TRW')
        types.VERY_LONG = [types.VERY_LONG; r_info];
        t_lbl=1;
        
    elseif strcmp(type,'Long TRW')
        types.LONG = [types.LONG; r_info];
        t_lbl=2;
        
    elseif strcmp(type,'Intermid TRW')
        types.INTERM = [types.INTERM; r_info];
        t_lbl=3;
        
    elseif strcmp(type,'Short TRW')
        types.SHORT = [types.SHORT;r_info];
        t_lbl=4;
        
    elseif strcmp(type,'Wierd')
        types.WIERD = [types.WIERD; r_info sig_p];
        t_lbl=5;
    end
    
    type_img(atlas==roi_lbl)=t_lbl;
    final_types(roi) = t_lbl;
    
    
    %     if (ismember(roi_lbl,t_relevant_labels))
    %         plot_roi(roi_means,SEs,roi_name,type,r_size,sig_p)
    %     end
end

final_lbls  = [final_r_info(:,1)];
final_names = [final_r_info(:,2)];
rois_size = [final_r_info(:,3)];



final_tbl = table(final_lbls,final_names,rois_size,final_r_means,final_r_SE,final_types);
out_xls = fullfile(isc_dir, 'final_rois_table.xls');
if ~exist(fullfile(out_xls))
    writetable (final_tbl,out_xls)
end


for t = 1:5
    t_fout =  [fout '_t' num2str(t)];
    t_img = type_img;
    t_img(t_img~=t)=0;
    niftiwrite(single(t_img),t_fout,niiInfo)
end

if ~exist([fout '.nii'])
    type_img(type_img==5)=0;
    niftiwrite(single(type_img),fout,niiInfo)
end

% trws = fieldnames(types);
% for TRW=1:length(trws)
%     figure;
%     rois = types.(trws{TRW});
%     for r = 1:size(rois,1)
%         ind = rois{r,4};
%         roi_means= final_r_means(ind,:);
%         SEs=final_r_SE(ind,:);
%         info=final_r_info(ind,:);
%         r_size=info{3};
%         roi_name=info{2};
%         sig_p=sig_ps (ind,:);
%         subplot(ceil(size(rois,1)/4),4,r);
%
%         plot_roi(roi_means,SEs,roi_name,trws{TRW},r_size,sig_p)
%     end
% end
save(fullfile(isc_dir, 'types.mat'),'types')

end




