package com.kata.foobarquix.controller;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/batch")
public class BatchController {

    private final JobLauncher jobLauncher;
    private final Job numberTransformationJob;

    public BatchController(JobLauncher jobLauncher, Job numberTransformationJob) {
        this.jobLauncher = jobLauncher;
        this.numberTransformationJob = numberTransformationJob;
    }

    @PostMapping("/process")
    public ResponseEntity<String> processBatch() {
        try {
            JobParameters jobParameters = new JobParametersBuilder()
                    .addLong("time", System.currentTimeMillis())
                    .toJobParameters();

            jobLauncher.run(numberTransformationJob, jobParameters);
            
            return ResponseEntity.ok("Traitement par lot terminé. Vérifiez le fichier output/result.txt");
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body("Erreur lors du traitement par lot: " + e.getMessage());
        }
    }
}