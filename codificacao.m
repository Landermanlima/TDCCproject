clc; clear all; close all;

%----------------------------Specifications-----------------------------------------------------------

SNRdb = (0:2:10);

nbinmsg = 1e5;

nbitsmsg = 100;

% Obs.: The generators below are not in the delay domain

% Cod1: Input m(D) | Output c1(D) = m(D) , c2(D) = m(D)(1 + D + D^2 + D^4)

trelliscod1 = poly2trellis(5,[20 35]);       % K = 1, N = 2

% Cod2: Input m(D) | Output c1(D) = m(D) , c2(D) = m(D)(1 + D + D^2 + D^4)/(1 + D + D^2 + D^3 + D^4)

trelliscod2 = poly2trellis(5,[37 35],37);    % K = 1, N = 2

tbdepth = 20; % A rate 1/2 code has a traceback depth of 5(ConstraintLength – 1).


%------------------------------Initial----------------------------------------------------------------


BER = zeros(length(SNRdb),1);
BERcod1 = zeros(length(SNRdb),1);
BERcod2 = zeros(length(SNRdb),1);

K = log2(trelliscod1.numInputSymbols);


%----------------------------Simulation---------------------------------------------------------------


for iii = 1:length(SNRdb)
    
	EbN0db = SNRdb(iii);

    disp(['Starting SNR = ' int2str(EbN0db) ' dB ...']);
    
    EbN0 = 10^(EbN0db/10); 
    N0 = 1/EbN0;
    sigma2 = N0/2;
    nbits = 0;
    nerr = 0; nerrcod1 = 0; nerrcod2 = 0;
    
    for ii = 1:nbinmsg
   
    	msg = randi([0 1],K*nbitsmsg,1);

    	noise = sqrt(sigma2)*randn(nbitsmsg,1); 
    	noisecod = sqrt(sigma2)*randn(2*nbitsmsg,1); % Because N = 2

    	%---------------------No code---------------------------------

    	raw = msg;
        
      
        for i = 1:length(raw)  % signaling

            if (raw(i) == 0)

            	raw(i) = -1;
           
           	end
       
       	end

       	% After AWGN channel
     
    	msgrx = raw + noise;
      
        for k2 = 1:length(msgrx)  % filtering

            if (msgrx(k2) >= 0)

                msgrx(k2) = 1;

            else

                msgrx(k2) = -1;

            end

        end

    	%---------------------Code 1---------------------------------

    	% Coding msg
      
    	cod1 = convenc(msg,trelliscod1);
            
        for p = 1:length(cod1) % signaling

        	if (cod1(p) == 0)

            	cod1(p) = -1;

			end
        
        end

        % After AWGN channel
    
        msgrx1 = cod1 + noisecod;
    
        for k = 1:length(msgrx1) % filtering

        	if (msgrx1(k) >= 0)

                msgrx1(k) = 1;

            else

                msgrx1(k) = -1;

            end

        end
            
        for p1 = 1:length(msgrx1) % inverting signaling

            if (msgrx1(p1) == -1)

            	msgrx1(p1) = 0;

            end

        end

        % Decoding msg

    	msghat1 = vitdec(msgrx1,trelliscod1,tbdepth,'trunc','hard');    
        
        for p2 = 1:length(msghat1) % signaling

            if (msghat1(p2) == 0)

            	msghat1(p2) = -1;

            end

        end

        %---------------------Code 2---------------------------------

        % Coding msg

    	cod2 = convenc(msg,trelliscod2);
    
    	for p3 = 1:length(cod2) %signaling

    		if (cod2(p3) == 0)

      			cod2(p3) = -1;
            
        	end

     	end

     	% After AWGN channel
 
        msgrx2 = cod2 + noisecod;
     
    	for k1 = 1:length(msgrx2) % filtering

        	if (msgrx2(k1) >= 0)

            	msgrx2(k1) = 1;

            else

                msgrx2(k1) = -1;

            end

		end

            
        for p4 = 1:length(msgrx2) % inverting signaling

        	if (msgrx2(p4) == -1)

            	msgrx2(p4) = 0;

            end

        end

        % Decoding msg
            
		msghat2 = vitdec(msgrx2,trelliscod2,tbdepth,'trunc','hard');        
            
        for p5 = 1:length(msghat2) % signaling

        	if (msghat2(p5) == 0)

            	msghat2(p5) = -1;

            end

    	end

    	

        %---------------------BER---------------------------------

        nbits = nbits + 100; % refresh number of bits transmitted
            
        for l = 1:length(raw)

        	nerr = nerr + abs(msgrx(l) - raw(l))/2; 
            nerrcod1 = nerrcod1 + abs(msghat1(l) - raw(l))/2;
            nerrcod2 = nerrcod2 + abs(msghat2(l) - raw(l))/2;
            
        end

    end 

    BER(iii,1) = nerr/nbits;
    BERcod1(iii,1) = nerrcod1/nbits;
    BERcod2(iii,1) = nerrcod2/nbits;   
    
end

figure();
semilogy(SNRdb,BER,'b+-','LineWidth',2);
hold on;
semilogy(SNRdb,BERcod1,'ro:','LineWidth',2);
semilogy(SNRdb,BERcod2,'g+-','LineWidth',2);
xlabel('SNR (dB)');
ylabel('BER');
legend('Sem codificação','Codificação não recursiva','Codificação recursiva');
grid();

