package com.kata.foobarquix;

import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableBatchProcessing
public class FooBarQuixApplication {

    public static void main(String[] args) {
        SpringApplication.run(FooBarQuixApplication.class, args);
    }
}