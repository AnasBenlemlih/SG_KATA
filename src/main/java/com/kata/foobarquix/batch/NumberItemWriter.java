package com.kata.foobarquix.batch;

import com.kata.foobarquix.model.NumberRecord;
import org.springframework.batch.item.Chunk;
import org.springframework.batch.item.ItemWriter;
import org.springframework.stereotype.Component;

import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

@Component
public class NumberItemWriter implements ItemWriter<NumberRecord> {

    @Override
    public void write(Chunk<? extends NumberRecord> chunk) throws Exception {
        // Créer le dossier output s'il n'existe pas
        if (!Files.exists(Paths.get("output"))) {
            Files.createDirectories(Paths.get("output"));
        }

        try (FileWriter writer = new FileWriter("output/result.txt", true)) {
            for (NumberRecord record : chunk) {
                if (record != null) {
                    writer.write(record.toString() + System.lineSeparator());
                }
            }
        } catch (IOException e) {
            throw new Exception("Erreur lors de l'écriture du fichier de sortie", e);
        }
    }
}