package com.kata.foobarquix.config;

import com.kata.foobarquix.batch.NumberItemProcessor;
import com.kata.foobarquix.batch.NumberItemReader;
import com.kata.foobarquix.batch.NumberItemWriter;
import com.kata.foobarquix.model.NumberRecord;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

@Configuration
public class BatchConfig {

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private PlatformTransactionManager transactionManager;

    @Autowired
    private NumberItemReader numberItemReader;

    @Autowired
    private NumberItemProcessor numberItemProcessor;

    @Autowired
    private NumberItemWriter numberItemWriter;

    @Bean
    public Job numberTransformationJob() {
        return new JobBuilder("numberTransformationJob", jobRepository)
                .start(transformNumbersStep())
                .build();
    }

    @Bean
    public Step transformNumbersStep() {
        return new StepBuilder("transformNumbersStep", jobRepository)
                .<Integer, NumberRecord>chunk(10, transactionManager)
                .reader(numberItemReader)
                .processor(numberItemProcessor)
                .writer(numberItemWriter)
                .build();
    }
}