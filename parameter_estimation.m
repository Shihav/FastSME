                               [valk,idmax] = max(timk,[],3); 
                             k=size(Img,3);
%% Finding the Lambda(W1) parameter
                                 [ncf,hcf]=hist(valk(edgeflag2==1),linspace(min(valk(:)),max(valk(:)),100));
                                    ncf=ncf/sum(ncf);

                                [ncb,hcb]=hist(valk(edgeflag2==0.5),linspace(min(valk(:)),max(valk(:)),100));
                                    ncb=ncb/sum(ncb); 
                                    
nt= find(ncb>ncf,1,'last');
ht=hcb(nt); 
idmaxini=idmax;

overlap2=sum(valk(edgeflag2==1)<=ht)./sum(valk(edgeflag2==1)>ht);

                    edgeflag2B = padarray(edgeflag2',1,'symmetric');
                     edgeflag2IB = padarray(edgeflag2B',1,'symmetric');
                     
                     base1=find_base2(edgeflag2IB,3);  
                       class3=sum(base1==1,3);   

                      idmaxk=idmax;
                     
                         idmaxkB = padarray(idmaxk',1,'symmetric');
                     IB = padarray(idmaxkB',1,'symmetric');

                     base=find_base(IB,3);
                           Mold=mean(base,3); 
                         varold2=sum((base-repmat(Mold,[1 1 8])).^2,3);
                         
                         M10=idmaxk-Mold;
                          MD=Mold-Mold;

                           s01=sqrt((varold2+(M10).*(idmaxk-(Mold+(M10)./9)))./8);
                          
                           sD=sqrt((varold2+(MD).*(Mold-(Mold+(MD)./9)))./8);
                           
                           sgain=s01-sD;
                           dD=abs(idmax-Mold);
                           sg=sgain(class3>8 & edgeflag2==1);
                           dg=dD(class3>8 & edgeflag2==1);
                           
                          sgk=sg;
                           sg(sgk==0)=[];
                           dg(sgk==0)=[];
%                            overlap2;
                           if overlap2<0
                               overlap2=0;
                           elseif overlap2>.5
                               overlap2=.5;
                           end
%                          overlap2; 
                           
                           WA=dg./sg;
                           lambda1=abs(quantile(WA(:),overlap2));
%                            if lambda1>15
%                                lambda1=15;
%                            end
                           
%                            if WW<9
%                                WW=9;
%                            end
                                  
%% Finding the Lambda(W1) parameter

edge1=edgeflag2==1;
edge5=edgeflag2==.5;
edge0=edgeflag2==0;

npxl1=sum(edge1(:));
npxl5=sum(edge5(:));
npxl0=sum(edge0(:));

meanfg=mean(valk(edge1));
meansfg=mean(valk(edge5));
meanbg=mean(valk(edge0));


RT=(meansfg-meanbg)./(meanfg-meanbg);

CD=3/3;
C1=CD*1./lambda1;
C2=CD*RT./lambda1;
C3=CD*0./lambda1;

WW=1;

edgeflag3k(edge1)=C1;  
edgeflag3k(edge5)=C2; 
edgeflag3k(edge0)=C3;  
                                                             
shiftc=zeros(size(edgeflag2));