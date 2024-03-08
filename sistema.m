function performanceBSP = sistema(S)
    %-----Parametri distribuzione delle domande ai diversi rivenditori-----%
    % stagione_1 = [90, 100, 100, 100, 130, 200, 200];
    % ev_1 = 100;
    % std_1 = 15;
    % distr_1 = 'Normal'; %'Poisson'
    % 
    % stagione_2 = [90, 100, 100, 100, 130, 200, 200];
    % ev_2 = 200;
    % std_2 = 20;
    % distr_2 = 'Normal'; %'Poisson'

    
    %-----Parametri prodotto-----%
    c = 7; % Costo del prodotto
    p = 10; % Prezzo di vendita
    q = 8; % Penalità per la vendita persa
    shelfLife = 12;
    
    %-----Parametri simulazione-----%
    orizzonteTemp = 52*7; % Periodi di tempo
    flag = 1; % 0: FIFO, 1: LIFO;
    wPolicy = 0;
    rPolicy = 0;
    leadTime = [8,9];
    
    %-----Inizializzazione-----%
    numR = 2;
    stockIniziale = zeros(shelfLife, numR);
    stockIniziale(end, 1:2) = 500;
    invIniziale = zeros(shelfLife, 1);
    invIniziale(end) = 1000;
    h = 1; % costo di magazzino (potrebbe essere anche un vettore se abbiamo costi differenti per ogni rivenditore
    
    
    %-----Definizione dei livelli e scenari-----%
    r = Rivenditore.empty(numR,0);
    t = Trasporto.empty(numR,0);
    for k = 1:numR
        r(k) = Rivenditore(stockIniziale(:,k), h, leadTime(k));
        t(k) = Trasporto(zeros(shelfLife, r(k).leadTime));
    end
    w = Magazzino(invIniziale, 4);
    
    %-----Upload degli scenari di domanda-----%
    scenario = zeros(2,10,orizzonteTemp);
    load('scenarioR1.mat'); % Scenari già creati 
    load('scenarioR2.mat');
    scenario(1,:,:) = scenarioR1(:, 1:orizzonteTemp);
    scenario(2,:,:) = scenarioR2(:, 1:orizzonteTemp);
    clear scenarioR1
    clear scenarioR2
    s = 3; % indica quale scenario stiamo considerando
    
    %-----Statistiche-----%
    ordinato = zeros(orizzonteTemp, 1); % Numero di prodotti ordinati dal magazzino
    vendite = zeros(orizzonteTemp, numR); % Numero di vendite effettuate in ogni periodo da ogni negozio
    holding = zeros(orizzonteTemp, numR); % Numero di prodotti immagazzinati all'inizio di ogni periodo per ogni negozio 
    lostSale = zeros(orizzonteTemp, numR); % Numero di possibili vendite perse in ogni periodo da ogni negozio
    scartoW = zeros(orizzonteTemp,1); % Numero di prodotti scartati dal Magazzino in ogni periodo
    scarto_r = zeros(orizzonteTemp, numR); % Numero di prodotti scartati in ogni periodo di tempo da ogni negozio
    
    %-----Simulazione-----%
    w.riceviOrdini([0 r(1).leadTime; 0 r(2).leadTime]); % Inizializzazione ordini
    for i = 1:orizzonteTemp % Indice periodo
        w.agg_Inv_InTrans();
        for k = 1:numR % Indice rivenditore
            r(k).aggInv(t(k).consegna()); % Arrivo merce al rivenditore k
            holding(i,k)=sum(r(k).inventario); % Calcoliamo il numero di prodotti all'inizio del periodo di tempo i
        end
        O = w.evadiOrdini(); % Il magazzino invia gli ordini ricevuti alla fine del periodo di tempo i-1
        for k = 1:numR % Indice rivenditore
            t(k).carico(O(:,k)); % Gli ordini inviati dal magazzino vengono inseriti sul nastro di trasporto
            [vendite(i,k), lostSale(i,k)] = r(k).vendita(flag, scenario(k,s,i));
            scarto_r(i,k) = r(k).aggVita(); % Aggiorno la vita dei prodotti e segno quanti ne ho scartati nel rivenditore k-esimo
            t(k).aggVita(); % Aggiorno la vita dei prodotti nel trasporto
        end
        scartoW(i) = w.aggVita(); % Aggiorno la vita dei prodotti e segno quanti ne ho scartati nel magazzino
        
        % Ordini del magazzino
        switch wPolicy
            case 0 % Constant order policy
                qOrdine = S(1);
%             case 1 % Base-stock order policy
%                 qOrdine = max(0, S(1) - (sum(w.inventario) + sum(w.inTransito))); % Ordino una quantità che mi fa arrivare al livello S(1)
        otherwise
            qOrdine = 0;
        end
        w.emettiOrdine(qOrdine);
        ordinato(i) = qOrdine;

        % Ordini dei rivenditori
        switch rPolicy
            case 0 % Constant order policy
                qOrdine_1 = S(2);
                qOrdine_2 = S(3);
%             case 1 % Base-stock order policy
%                 qOrdine_1 = max(0, S(2) - (sum(r(1).inventario) + sum(t(1).nastro,"all"))); % Indice shiftato in avanti di uno perché S(1) è magazzino
%                 qOrdine_2 = max(0, S(3) - (sum(r(2).inventario) + sum(t(2).nastro,"all"))); % Indice shiftato in avanti di uno perché S(1) è magazzino
        otherwise
            qOrdine_1 = 0;
            qOrdine_2 = 0;
        end
        w.riceviOrdini([qOrdine_1 r(1).leadTime; qOrdine_2 r(2).leadTime]); % Inoltro gli ordini al magazzino
    end
    performanceBSP = c*sum(ordinato) + h*sum(holding,"all") + q*sum(lostSale,"all") - p*sum(vendite,"all");
end
