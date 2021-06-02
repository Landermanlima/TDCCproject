clc; clear all; close all;

%Codificação em um canal AWGN.
%Transmissão dos bits, vetor mensagem "m":

EBN0dbv=(0:2:10); %vetor de razão sinal ruído a ser simulado
BER=zeros(length(EBN0dbv),1);
BERcod2=zeros(length(EBN0dbv),1);
tbdepth=[1 20 35];
tbdepth_value = zeros(length(BERcod2),length(tbdepth));

%Para os devidos valores de razão sinal ruído

for iv=1:length(tbdepth)
    
for iii=1:length(EBN0dbv)
    
    EBN0db=EBN0dbv(iii);
    disp(['iniciando EB/N0=' int2str(EBN0db) 'dB']);
    
    EBN0=10^(EBN0db/10); %Fazendo a transformação inversa de dB
    %Faremos    Eb=1 , N0=1/EBN0
    N0=1/EBN0;
    sigma2=N0/2;
    
    nerrncod=0; nbits=0; nerrcod2=0;
    
    for ii=1:100000
        
    %Vetor mensagem com 100 bits    
        bits = randi([0 1],100,1);
  %%      
        nv=sqrt(sigma2)*randn(100,1); %vetor de amostras do ruído AWGN
        nvcod=sqrt(sigma2)*randn(200,1); %vetor de amostras do ruído AWGN para o codificado (dobro de amostras para esse caso)
  %%    
   
    %Codificador 2, recursivo:
    trelliscod2 = poly2trellis(5,[37 35],37 );
    cod2 = convenc(bits,trelliscod2);
    
     for p3=1:length(cod2)   
            if cod2(p3)==0
             cod2(p3)=-1;
            end
     end
 
     message_cod2 = cod2 + nvcod;
     
     for k1=1:length(message_cod2)
                if message_cod2(k1)>=0
                message_cod2(k1)=1;
                else
                message_cod2(k1)=-1;
                end
     end
            
            for p4=1:length(message_cod2)   
            if message_cod2(p4)==-1
             message_cod2(p4)=0;
            end
            end
            
    
    decodecod2 = vitdec(message_cod2,trelliscod2,tbdepth(iv),'trunc','hard');        
            
    
     for p5=1:length(decodecod2)  
            if decodecod2(p5)==0
             decodecod2(p5)=-1;
            end
     end
        
 %%       
        for i=1:length(bits)   
            if bits(i)==0
             bits(i)=-1;
            end
        end
     
    

    nbits = nbits + length(bits); %Atualização da quantidade de bits (para cada RSR)
%%   
            %Atualizando o n° de erros:
                for l=1:length(bits)
                    nerrcod2 = nerrcod2 + abs(decodecod2(l) - bits(l))/2;
                end
%%             
   end 
   
   BERcod2(iii,1) = nerrcod2/nbits;
%%    
    
end

tbdepth_value(:,iv) = BERcod2;

end

figure();
semilogy(EBN0dbv,tbdepth_value(:,1),'b+-','LineWidth',2);
hold on;
semilogy(EBN0dbv,tbdepth_value(:,2),'ro:','LineWidth',2);
semilogy(EBN0dbv,tbdepth_value(:,3),'g+-','LineWidth',2);
xlabel('EBN0(dB)');
ylabel('BER');
legend('tbdepth= 1 ','tbdepth= 20' ,'tbdepth= 35' );
grid();

