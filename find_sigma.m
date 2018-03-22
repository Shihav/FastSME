function [sig]=find_sigma(Img)
% Img=Img1;
M = [-1 2 -1];
val=[];
sigpool=[0:0.25:2.25];

for k=1:size(Img,3)
       sn=1;
       valn=[];
              for signk=sigpool   
                    if signk>0        
                        hG = fspecial('gaussian',[25 25],signk);  
                    end
     
                   timg=Img(:,:,k); 

                  if signk>0
                      timg = imfilter(timg,hG,'symmetric');  
                  end

                      Gx = imfilter(timg, M, 'replicate', 'conv');
                      Gy = imfilter(timg, M', 'replicate', 'conv');
                      timkn=abs(Gx) + abs(Gy);
                      ima=max(timkn(:));
                      imi=min(timkn(:));
                      ims=std(timkn(:));
                      snrk=20*log10((ima-imi)./ims);
                      
                      valn(1,sn)=snrk;
                      sn=sn+1;
              end
              
              val(k,:)=valn;
end  
               sigA=mean(val,1);
               [~,mp]=max(sigA);
               sig=sigpool(mp);