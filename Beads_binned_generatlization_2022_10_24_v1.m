function Beads_binned_generatlization(in_path ,varargin)

title_name='';
if length(varargin)>0
    for i = 1:2:length(varargin),
        theparam = lower(varargin{i});
        switch(strtok(theparam)),
            case 'name',
                title_name=varargin{i+1};
        end;
    end
end

%checking input path
if in_path(end)~='\';
    in_path=[in_path,'\'];
end

load([in_path,'\Sbeads_001-1.mat']);
cen=reshape([Sbeads_001.Centroid],2,[])';
Val=reshape([Sbeads_001.mean],2,[])';

%Getting im size
im=imread([in_path,'beads_001-01-p.tif']);
im_size=size(im);
bin_size_ref=2048/24;

%setting input parameters
xbins=round(im_size(2)/bin_size_ref);
ybins=round(im_size(1)/bin_size_ref);
imx=im_size(2);
imy=im_size(1);
xsize=imx/xbins;
ysize=imy/ybins;

pix_mean=zeros(ybins,xbins);
pix_median=zeros(ybins,xbins);
pix_mode=zeros(ybins,xbins);

for x=1:xbins
    for y=1:ybins
        good_val=cen(:,1)>=(0+xsize*(x-1))&cen(:,1)<(xsize*x)...
            &cen(:,2)>=(0+ysize*(y-1))&cen(:,2)<(ysize*y);
        val_use=Val(good_val,2);
        pix_mean(y,x)=mean(val_use);
        pix_median(y,x)=median(val_use);
        pix_mode(y,x)=mode(val_use);
    end
end



%Center quadrant
data_do{1}=pix_mean;
if  xbins~=24||ybins~=24
    [~,ind]=max(sum(pix_mean,1,'omitnan'));
    [~,ind2]=max(sum(pix_mean,2,'omitnan'));
    good_ind=round([ind,ind2]);
    part=pix_mean(ind2-12:ind2+12,ind-12:ind+12);
    part_cen=pix_mean(ybins/2-12:ybins/2+12,xbins/2-12:xbins/2+12);
    data_do{2}=part;
    data_do{3}=part_cen;
end
%plotting data

aa={[0,xbins,0,ybins],[0,25,0,25],[0,25,0,25]};
%data_name={'Nikon QI2 YFP','Nikon QI2 YFP center best','Nikon QI2 YFP center'};
if length(title_name)>1
    data_name={[title_name,' YFP'],[title_name,' YFP center best'],[title_name,' YFP center']};
else
    data_name={['YFP'],['YFP center best'],['YFP center']};
end

for i=1:length(data_do)
    figure;
    surf(data_do{i}/max(data_do{i}(:))); 
    colormap('jet');
    colorbar;
    view(0,-90);
    axis(aa{i});
    a=get(gca);
    new_ylabel=cellfun(@(x) num2str(round(str2num(x)*ysize)),a.YTickLabel,'UniformOutput',false);
    new_xlabel=cellfun(@(x) num2str(round(str2num(x)*xsize)),a.XTickLabel,'UniformOutput',false);
    set(gca,'XTickLabel',new_xlabel,'YTickLabel',new_ylabel);
    xlabel('Pixel [au]');
    ylabel('Pixel [au]');
    title(data_name{i});
end
