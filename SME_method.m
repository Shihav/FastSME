function Manifold=SME_method(Img,ButtonName,mkp)
% Img=Img1;
% ButtonName='confical'
%This funtion finds the single manifod in the stack where the object is located. The final output should be the image created from that manifold. The input image should be a stack.

M = [-1 2 -1];%SML operator
[sz1,sz2,sz3]=size(Img);
npxl=sz1*sz2;
timk=double(Img);

if strcmp(ButtonName,'Widefield (WF)')
     if sqrt(npxl)>=4096
        sigma=find_sigma_par(Img);
     else
        sigma=find_sigma(Img);
     end
hG = fspecial('gaussian',[25 25],sigma+0.01); 

%% SML Extraction
               for k=1:size(Img,3)
                   timg=Img(:,:,k);   
                    timg = imfilter(timg,hG,'symmetric');  
                      Gx = imfilter(timg, M, 'replicate', 'conv');
                      Gy = imfilter(timg, M', 'replicate', 'conv');
                      timk(:,:,k) = abs(Gx) + abs(Gy);
               end   
end
      
%% Fourier transform and kmeans
               class=3;%background, uncertain and foreground
               Norm=2;
               zprof2=reshape(timk,[size(Img,1)*size(Img,2) size(Img,3)]); 
               
                       tempt=abs(fft(zprof2,size(Img,3),2));
                       tempt(:,[1 ceil(size(Img,3)/2)+1:end])=[];

               tempt=tempt./repmat((max(tempt,[],1)-min(tempt,[],1)),[size(tempt,1) 1]);
               if sqrt(npxl)>=4096
               pool = parpool;                      % Invokes workers
               stream = RandStream('mlfg6331_64');
               options = statset('UseParallel',1,'UseSubstreams',1,...
                         'Streams',stream);
               [idx,c]=kmeans(tempt,class,'Options',options);
               else
                   [idx,c]=kmeans(tempt,class);
               end
                [~,I] = sort(sum(c(:,1),2),1);
                idxt=idx;

                ct=c;
                    for cng=1:size(I,1)
                        idx(idxt==I(cng))=cng;
                        c(cng,:)=ct(I(cng),:);
                    end

                     edgeflag=reshape(idx,[size(Img,1) size(Img,2)]); 
                 edgeflag2=double((edgeflag-1)/Norm); 
                  edgeflag3k=double((edgeflag-1)/2); 
%                   edgeflag3k(edgeflag3k==1/2)=0;

%% Parameter settings                 
parameter_estimation

%% Minimizations         
 Optimization_SME

 Manifold=idmaxk;%final Z map

                       
