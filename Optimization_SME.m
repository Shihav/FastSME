%% Finding step size and stopping criteria(epsilon) relative to stack size
                KE= max(idmax(edgeflag2>0))- min(idmax(edgeflag2>0))+1;  
                step=KE/100; 
%% pyramid scheme of resolusion starting
  if sqrt(npxl)<=512    
      ratio=[1];
  elseif sqrt(npxl)>512 && sqrt(npxl)<=1024
      ratio =[.5 1];
  elseif sqrt(npxl)>1024 && sqrt(npxl)<=2048
      ratio=[.25 .5 1];
  elseif sqrt(npxl)>2048 && sqrt(npxl)<=4096
      ratio=[0.125 .25 .5 1];
  elseif sqrt(npxl)>4096 && sqrt(npxl)<=8192
      ratio=[0.0625 0.125 .25 .5 1];
  elseif sqrt(npxl)>8192
      ratio=[0.03125 0.0625 0.125 .25 .5 1];
  end
%   Miter=0;
  idmaxk=idmax;
  costA=[];
  for rn=1:length(ratio)
      sratio=round(ratio(rn)*size(idmax));
      srn=ratio(rn)*ratio(rn);
             
             idmaxk=imresize(idmaxk,sratio,'nearest');
             idmaxk2=imresize(idmax,sratio,'nearest');
             edgeflag3k2=imresize(edgeflag3k,sratio,'nearest');
             edge12=imresize(edge1,sratio,'nearest');
             edge52=imresize(edge5,sratio,'nearest');
             edge02=imresize(edge0,sratio,'nearest');
             shiftc2=imresize(shiftc,sratio,'nearest');
       cost=[];         
             
              cost(2)=10;%2 fake values to enter while loop; to be ignored later
               cost(1)=100;
             iter=2;
             lim=(1)./ratio(rn);
             
             %% Optimization starts
      while abs((cost(iter)))>((0.0001*KE*lim))
%                  Miter=Miter+1;
                    iter=iter+1;
                    idmax1=idmaxk+step;
                     idmax2=idmaxk-step;
                     
                      idmaxkB = padarray(idmaxk',1,'symmetric');
                     IB = padarray(idmaxkB',1,'symmetric');
                     
                     base=find_base(IB,3);
                           Mold=mean(base,3); 
                         varold2=sum((base-repmat(Mold,[1 1 8])).^2,3);
          %% gradient decent momentum starts           
                     d1=abs(idmaxk2-idmax1).*edgeflag3k2;
                       d2=abs(idmaxk2-idmax2).*edgeflag3k2;

                         M11=idmax1-Mold;
                         M12=idmax2-Mold;
                         
                             s1=WW*sqrt((varold2+(M11).*(idmax1-(Mold+(M11)./9)))./8);
                         s2=WW*sqrt((varold2+(M12).*(idmax2-(Mold+(M12)./9)))./8);
                                                 
                             c1=d1+s1;
                             c2=d2+s2;

dt=c1-c2;
  shiftc2=0.5*shiftc2+50*dt*step;  
  %% to plot the index map at each step
 if mkp==1 
  figure(rn)
%                           imagesc(idmaxk)
%                                       colormap(bone) 
            imagesc(idmaxk);
%             axis tight
            caxis manual
            caxis([1 size(Img,3)]);
            colorbar
 end

                idmaxk=idmaxk-shiftc2;
                %% gradient decent momentum ends
                
                %% new cost function
     cost(iter)=sum(abs(dt(edge12)))/(srn*npxl1)+sum(abs(dt(edge52)))/(srn*npxl5)+sum(abs(dt(edge02)))/(srn*npxl0);
     step=step*0.99;
%      cost(iter)
%      iter
%                 Miter
      end
     

%                 cost(1:2)=[];
%                 costA=[costA cost];
  end            

cost=costA;
 