package com.kata.foobarquix.batch;

import org.springframework.batch.item.ItemReader;
import org.springframework.batch.item.NonTransientResourceException;
import org.springframework.batch.item.ParseException;
import org.springframework.batch.item.UnexpectedInputException;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

@Component
public class NumberItemReader implements ItemReader<Integer> {

    private BufferedReader reader;

    @Override
    public Integer read() throws Exception, UnexpectedInputException, ParseException, NonTransientResourceException {
        if (reader == null) {
            try {
                reader = new BufferedReader(new FileReader("input/numbers.txt"));
            } catch (IOException e) {
                throw new RuntimeException("Impossible de lire le fichier input/numbers.txt", e);
            }
        }

        String line = reader.readLine();
        if (line == null) {
            reader.close();
            return null; // Fin du fichier
        }

        try {
            return Integer.parseInt(line.trim());
        } catch (NumberFormatException e) {
            // Ignorer les lignes non numériques et lire la suivante
            return read();
        }
    }
}