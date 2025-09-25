package com.kata.foobarquix.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class NumberRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private int inputNumber;
    private String transformedResult;

    public NumberRecord() {}

    public NumberRecord(int inputNumber, String transformedResult) {
        this.inputNumber = inputNumber;
        this.transformedResult = transformedResult;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public int getInputNumber() {
        return inputNumber;
    }

    public void setInputNumber(int inputNumber) {
        this.inputNumber = inputNumber;
    }

    public String getTransformedResult() {
        return transformedResult;
    }

    public void setTransformedResult(String transformedResult) {
        this.transformedResult = transformedResult;
    }

    @Override
    public String toString() {
        return inputNumber + " \"" + transformedResult + "\"";
    }
}