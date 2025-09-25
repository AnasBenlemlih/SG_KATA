package com.kata.foobarquix.controller;

import com.kata.foobarquix.service.NumberTransformationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/transform")
public class NumberTransformationController {

    private final NumberTransformationService transformationService;

    public NumberTransformationController(NumberTransformationService transformationService) {
        this.transformationService = transformationService;
    }

    @GetMapping("/{number}")
    public ResponseEntity<Map<String, Object>> transformNumber(@PathVariable int number) {
        try {
            String result = transformationService.transform(number);
            return ResponseEntity.ok(Map.of(
                "input", number,
                "result", result
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", e.getMessage()
            ));
        }
    }
}