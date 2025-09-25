package com.kata.foobarquix.service;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class NumberTransformationService {

    /**
     * Transforme un nombre selon l'algorithme FOO BAR QUIX.
     * 
     * Règles :
     * - FOO : divisible par 3 OU contient le chiffre 3
     * - BAR : divisible par 5 OU contient le chiffre 5
     * - QUIX : contient le chiffre 7
     * 
     * Important : on applique TOUTES les règles qui matchent !
     */
    public String transform(int number) {
        if (number < 0 || number > 100) {
            throw new IllegalArgumentException("Le nombre doit être entre 0 et 100");
        }

        List<String> result = new ArrayList<>();
        String numberStr = String.valueOf(number);

        // Règles de divisibilité
        if (number % 3 == 0) {
            result.add("FOO");
        }
        if (number % 5 == 0) {
            result.add("BAR");
        }

        // Règles de contenu (s'ajoutent en plus des règles de divisibilité)
        // Compter chaque chiffre individuellement
        for (char digit : numberStr.toCharArray()) {
            if (digit == '3') {
                result.add("FOO");
            }
            if (digit == '5') {
                result.add("BAR");
            }
            if (digit == '7') {
                result.add("QUIX");
            }
        }

        // Si aucune règle ne s'applique, retourner le nombre original
        return result.isEmpty() ? numberStr : String.join("", result);
    }
}