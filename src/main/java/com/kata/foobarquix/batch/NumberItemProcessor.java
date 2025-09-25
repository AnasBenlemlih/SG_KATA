package com.kata.foobarquix.batch;

import com.kata.foobarquix.model.NumberRecord;
import com.kata.foobarquix.service.NumberTransformationService;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.stereotype.Component;

@Component
public class NumberItemProcessor implements ItemProcessor<Integer, NumberRecord> {

    private final NumberTransformationService transformationService;

    public NumberItemProcessor(NumberTransformationService transformationService) {
        this.transformationService = transformationService;
    }

    @Override
    public NumberRecord process(Integer number) throws Exception {
        try {
            String result = transformationService.transform(number);
            return new NumberRecord(number, result);
        } catch (IllegalArgumentException e) {
            // Ignorer les nombres invalides
            return null;
        }
    }
}