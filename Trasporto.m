classdef Trasporto < handle 
    %Definizione del processo di trasporto da un magazzino ai rivenditori
    properties
        nastro
    end

    methods
        function obj = Trasporto(inizio)
            obj.nastro = inizio;
        end

        function carico(obj, nuovoOrdine)
            % Carico l'ultimo ordine pervenuto sul nastro facendo scorrere
            % gli altri ordini
            obj.nastro(:,1:end-1) = obj.nastro(:,2:end); 
            obj.nastro(:, end) = nuovoOrdine;
        end

        function aggVita(obj)
            % Aggiorno la vita dei prodotti
            obj.nastro(1:end-1,:) = obj.nastro(2:end,:);
            obj.nastro(end,:) = zeros(1, size(obj.nastro, 2));
        end
        
        function c = consegna(obj)
            c = obj.nastro(:,1);
        end

    end
end