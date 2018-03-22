%% This is the main function of the FastSME. It can make both single or batch processing as selected by the user.
%% 
%

function FastSME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Makes a 2D reconstruction which is spatially continuous out of a 3D image volume
% Authors: ASM Shihavuddin(shihav@dtu.dk), Sreetama Basu     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear all;close all;

%% Selection of the processing type (Batch or single)
%
        PTYPE = questdlg('How to process?', ...
                         'How to process?', ...
                         'Single image', 'Batch processing', 'Single image');

if strcmp(PTYPE,'Single image')
%% Read the TIF file
% Selecting the input image
[FileName,PathName] = uigetfile({'*.tif';'*.tiff'},'Select the input tif or tiff file');
dname = PathName;
[filepath,name,ext] = fileparts(FileName);

% draw the interation process? (1=yes, 0=no)
mkp=0;

   ButtonName = questdlg('Imaging modality?', ...
                         'Imaging modality', ...
                         'Confocal (CF)', 'Widefield (WF)', 'Confocal (CF)');
                     
prompt={'How many channels are there?','Which is your reference channel?','How many Layer to add above manifold?','How many Layer to add below manifold?'};
title='User interface'; 
defaultanswer = {'1','1','0','0'};
numlines=1;
answer=inputdlg(prompt,title,numlines,defaultanswer);
NCH = str2double(answer{1}); 
RCH = str2double(answer{2});
UCH = str2double(answer{3}); 
BCH = str2double(answer{4});

layer_up=UCH;
layer_down=BCH;
% profile on
tic
fname = FileName;

%%%%%%%%%%%%%%%%%%%example 1
mkdir([dname filesep strrep(fname,ext,'') '_Results'])
nametex=[dname filesep strrep(fname,ext,'') '_Results' filesep strrep(fname,ext,'')];
nametex2=[dname filesep strrep(fname,ext,'')];

info = imfinfo([PathName fname]);
num_images = numel(info);
h = max([info.Height]);
w = max([info.Width]);
l = length([info.FileSize])/NCH;
Img1 = zeros(h,w,l);
% Img1=[];

kin=1;
for k = RCH:NCH:num_images
    I = imread([PathName fname], k);
    Img1(:,:,kin)=I; 
    kin=kin+1;
end

% IM4=Img1; 
Img=Img1;
fname1=strrep(fname,ext,'');  

    if strcmp(ButtonName,'Confocal (CF)')
    TH='CF';
    elseif strcmp(ButtonName,'Widefield (WF)')
    TH='WF';
    end
    
    %% Calling the main SME function
    
    qzr2=SME_method(Img1,ButtonName,mkp); 
%     save qzr2fast2.mat qzr2
imwrite(uint16(qzr2),[nametex '_SME_ZMAP_ref' num2str(RCH) '_nCH' num2str(NCH) '_' TH ext]);
                             qzr2(qzr2>k)=k;
                             qzr2(qzr2<1)=1;

COLOR_SME=uint16(zeros(size(Img,1),size(Img,2),max([3 NCH])));
COLOR_MIP=uint16(zeros(size(Img,1),size(Img,2),max([3 NCH])));

for PCH=1:NCH
    
    if PCH==RCH
    Img2=Img1;   
    else
    Img2 = zeros(h,w,l);
%  Img2=[];
 
    kin=1;
    for k = PCH:NCH:num_images
        I = imread([PathName FileName], k);
        Img2(:,:,kin)=I; 
        kin=kin+1;
    end
    end
                    zmap=round(qzr2);
                    zmap(zmap>k)=k;
                    zmap(zmap<1)=1;
                    zprojf2=FV1_make_projection_from_layer(Img2,zmap,layer_up,layer_down);
                    COLOR_SME(:,:,PCH)=uint16(zprojf2);
%                     COLOR_MIP(:,:,PCH)=uint16(max(Img2,[],3));
                    imwrite(uint16(COLOR_SME(:,:,PCH)),[nametex '_SME_Projection_CH' num2str(PCH) '_ref' num2str(RCH) '_nCH' num2str(NCH) '_above' num2str(UCH) '_down' num2str(BCH) '_' TH ext]);                     
end   
precessingTime = toc
% profile viewer
% close all

elseif strcmp(PTYPE,'Batch processing')
    
%% Read the TIF file

dirM = uigetdir(cd,'Select the input folder containing tif or tiff files');
list1=dir(fullfile(dirM,'*.tif'));
list2=dir(fullfile(dirM,'*.tiff'));
list=[list1;list2];

dname = [dirM filesep];
PathName=dname;
mkp=0;

   ButtonName = questdlg('Imaging modality?', ...
                         'Imaging modality', ...
                         'Confocal (CF)', 'Widefield (WF)', '');
                     
prompt={'How many channels are there?','Which is your reference channel?','How many Layer to add above manifold?','How many Layer to add below manifold?'};
title='User interface'; 
defaultanswer = {'1','1','0','0'};
numlines=1;
answer=inputdlg(prompt,title,numlines,defaultanswer);
NCH = str2double(answer{1}); 
RCH = str2double(answer{2});
UCH = str2double(answer{3}); 
BCH = str2double(answer{4});

layer_up=UCH;
layer_down=BCH;

for rol=1:size(list,1)
FileName=list(rol).name;
[filepath,name,ext] = fileparts(FileName);
tic
fname = FileName;

%%%%%%%%%%%%%%%%%%%example 1
mkdir([dname 'Results'])
nametex=[dname 'Results' filesep strrep(fname,ext,'')];
nametex2=[dname filesep strrep(fname,ext,'')];

info = imfinfo([PathName fname]);
num_images = numel(info);
h = max([info.Height]);
w = max([info.Width]);
l = length([info.FileSize])/NCH;
Img1 = zeros(h,w,l);
% Img1=[];

kin=1;
for k = RCH:NCH:num_images
    I = imread([PathName fname], k);
    Img1(:,:,kin)=I; 
    kin=kin+1;
end

% IM4=Img1; 
Img=Img1;
fname1=strrep(fname,ext,'');  

    if strcmp(ButtonName,'Confocal (CF)')
    TH='CF';
    elseif strcmp(ButtonName,'Widefield (WF)')
    TH='WF';
    end
    
    qzr2=SME_method(Img1,ButtonName,mkp);
    imwrite(uint16(qzr2),[nametex '_SME_ZMAP_ref' num2str(RCH) '_nCH' num2str(NCH) '_' TH ext]);

                             qzr2(qzr2>k)=k;
                             qzr2(qzr2<1)=1;

COLOR_SME=uint16(zeros(size(Img,1),size(Img,2),max([3 NCH])));
COLOR_MIP=uint16(zeros(size(Img,1),size(Img,2),max([3 NCH])));

for PCH=1:NCH
    
    if PCH==RCH
    Img2=Img1;   
    else
    Img2 = zeros(h,w,l);
%  Img2=[];
 
    kin=1;
    for k = PCH:NCH:num_images
        I = imread([PathName FileName], k);
        Img2(:,:,kin)=I; 
        kin=kin+1;
    end
    end
                    zmap=round(qzr2);
                    zmap(zmap>k)=k;
                    zmap(zmap<1)=1;
                    zprojf2=FV1_make_projection_from_layer(Img2,zmap,layer_up,layer_down);
                    COLOR_SME(:,:,PCH)=uint16(zprojf2);
%                     COLOR_MIP(:,:,PCH)=uint16(max(Img2,[],3));
                    imwrite(uint16(COLOR_SME(:,:,PCH)),[nametex '_SME_Projection_CH' num2str(PCH) '_ref' num2str(RCH) '_nCH' num2str(NCH) '_above' num2str(UCH) '_down' num2str(BCH) '_' TH ext]);                     
end   
precessingTime = toc
delete(gcp('nocreate'))
% close all
end

end
