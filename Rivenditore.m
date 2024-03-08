classdef Rivenditore < handle
    properties
        inventario
        costoMagazzino
        leadTime
    end
    
    methods
        function obj = Rivenditore(stockIniziale, costoMagazzino, leadTime)
            obj.inventario = stockIniziale;
            obj.costoMagazzino = costoMagazzino;
            obj.leadTime = leadTime;
        end
        
        
        function aggInv(obj, inEntrata)
            % Aggiorna l'inventario con in nuovi prodotti in entrata
            obj.inventario = obj.inventario + inEntrata;
        end

        function scarto = aggVita(obj)
            %Aggiorna l'inventario buttando i prodotti scaduti (fine
            %giornata)
            scarto = obj.inventario(1);
            obj.inventario(1:end-1) = obj.inventario(2:end); 
            obj.inventario(end) = 0;
            return
        end

        function [venduto, perso] = vendita(obj, flag, domanda)
            %flag = 0: politica FIFO
            %flag = 1: politica LIFO
            restante = domanda;
            venduto = 0;
            if (sum(obj.inventario) >= 1)
                if(flag == 0)
                    for i=find(obj.inventario,1,'first'):find(obj.inventario,1,'last')
                        temp = min(obj.inventario(i),restante);
                        venduto = venduto + temp;
                        restante = restante - temp;
                        obj.inventario(i) = obj.inventario(i) - temp;
                        if(restante==0)
                            break;
                        end
                    end
                    perso = restante;
                elseif(flag == 1)
                    for i=find(obj.inventario,1,'last'):-1:find(obj.inventario,1,'first')
                        temp = min(obj.inventario(i),restante);
                        venduto = venduto + temp;
                        restante = restante - temp;
                        obj.inventario(i) = obj.inventario(i) - temp;
                        if(restante==0)
                            break;
                        end
                    end
                    perso = restante;
                else
                    venduto = 0;
                    perso = domanda;
                end
            else
                venduto = 0;
                perso = domanda;
            end
            return
        end
    end
end