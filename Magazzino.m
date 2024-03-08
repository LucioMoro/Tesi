classdef Magazzino < handle
    properties
        inventario
        inTransito
        ordini
        leadTime
    end
    
    methods
        function obj = Magazzino(invIniziale, leadTime)
            obj.inventario = invIniziale;
            obj.ordini = [];
            obj.leadTime = leadTime;
            obj.inTransito = zeros(1, obj.leadTime);
        end
        
        function agg_Inv_InTrans(obj)
            % Aggiorna l'inventario e gli ordini in transito verso il
            % magazzino
            obj.inventario(end) = obj.inTransito(1);
            obj.inTransito(1:end-1) = obj.inTransito(2:end); % Shifta di un periodo gli ordini in transito
            obj.inTransito(end) = 0;
        end

        function scarto = aggVita(obj)
            %Aggiorna l'inventario buttando i prodotti scaduti (fine
            %giornata)
            scarto = obj.inventario(1);
            obj.inventario(1:end-1) = obj.inventario(2:end); 
            obj.inventario(end) = 0;
            return
        end

        function emettiOrdine(obj, ordine)
            % Sottomette un ordine da parte del magazzino
            obj.inTransito(end) = ordine;
        end

        function riceviOrdini(obj, ordini)
            % Inserisce gli ordini ricevuti dai rivenditori ordinandoli da quello
            % con leadTime più alto
            obj.ordini = sortrows(ordini, 2, 'ascend');
        end

        function O = evadiOrdini(obj)
            % Resitituisce i prodotti da consegnare ai rivenditori (da caricare sul
            % Trasporto)
            v = length(obj.inventario); % Shelflife
            n = size(obj.ordini,1); % Numero rivenditori
            O = zeros(v,n);
            if sum(obj.ordini(:,1)) < sum(obj.inventario(obj.ordini(end,2)+1:end))
                % Se la somma degli ordini è inferiore alla somma dei
                % prodotti in inventario con tempo di vita rimasto maggiore
                % del leadTime minimo
                for i=1:n % Per ogni rivenditore                    
                    for j=obj.ordini(i,2)+1:v % Per ogni prodotto con vita > leadTime(j)
                        temp = min(obj.ordini(i,1), obj.inventario(j));
                        O(j,i) = O(j,i) + temp;
                        obj.inventario(j) = obj.inventario(j) - temp;
                        obj.ordini(i,1) = obj.ordini(i,1) - temp;
%                         if(~obj.ordini(i,1) || sum(obj.inventario(j:v))==0) 
%                               % Se ho soddisfatto l'ordine oppure
%                               % se la somma dell'inventario nelle celle
%                               % successive è 0
%                             break;
%                         end
                    end
                end
            else
                obj.ordini(:,1) = round(obj.ordini(:,1)/sum(obj.ordini(:,1)).*sum(obj.inventario(obj.ordini(end,2)+1:end)));
                for i=1:n
                    for j=obj.ordini(i,2)+1:v % Per ogni prodotto con vita > leadTime(j)
                        temp = min(obj.ordini(i,1), obj.inventario(j));
                        O(j,i) = O(j,i) + temp; % aggiungo i prodotti da spedire se ce ne sono con quella vita
                        obj.inventario(j) = obj.inventario(j) - temp;
                        obj.ordini(i,1) = obj.ordini(i,1) - temp; % sottraggo al numero di prodotti ancora da soddisfare quelli appena aggiunti all'ordine
%                         if(~obj.ordini(i,1) || sum(obj.inventario(j:v))==0) % Se ho soddisfatto l'ordine
%                             % Se ho soddisfatto l'ordine oppure
%                             % se la somma dell'inventario nelle celle
%                             % successive è 0
%                             break;
%                         end
                    end                    
                end
            end
        end
    end
end