classdef ScenarioRandom < handle
    properties
        stagione
        mu
        sigma
        distr
    end
    
    methods
        function obj = ScenarioRandom(stagione, mu, sigma, distr)
            stagioneAss = stagione;
            obj.stagione = stagioneAss / mean(stagioneAss); % normalizzato in modo che sommino a 7
            obj.mu = obj.stagione * mu; % valore atteso con stagionalità
            obj.distr = distr;
            obj.sigma = obj.stagione * sigma; % deviazione standard con stagionalità
        end
       
        function setSeed(obj, seed)
            % Reset del seed
            rng(seed);
        end
        
        function scenarioDomanda = creaScenario(obj, orizzonteTemp) 
            % Creazione scenario
            scenarioDomanda = zeros(1, orizzonteTemp);
            for i = 1:orizzonteTemp
                giorno = mod(i-1, 7) + 1; % da 1 Lunedì a 7 Domenica
                scenarioDomanda(i) = round(max(0, normrnd(obj.mu(giorno), obj.sigma(giorno))));
            end
            return
        end
    end
end