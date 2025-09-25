package com.kata.foobarquix.controller;

import com.kata.foobarquix.service.NumberTransformationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class NumberTransformationControllerTest {

    private NumberTransformationController controller;
    private NumberTransformationService transformationService;

    @BeforeEach
    void setUp() {
        transformationService = mock(NumberTransformationService.class);
        controller = new NumberTransformationController(transformationService);
    }

    @Test
    void testTransformNumber_ValidNumber_ShouldReturnOk() {
        // Given
        when(transformationService.transform(15)).thenReturn("FOOBARBAR");

        // When
        ResponseEntity<Map<String, Object>> response = controller.transformNumber(15);

        // Then
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(15, response.getBody().get("input"));
        assertEquals("FOOBARBAR", response.getBody().get("result"));
    }

    @Test
    void testTransformNumber_InvalidNumber_ShouldReturnBadRequest() {
        // Given
        when(transformationService.transform(101)).thenThrow(new IllegalArgumentException("Le nombre doit être entre 0 et 100"));

        // When
        ResponseEntity<Map<String, Object>> response = controller.transformNumber(101);

        // Then
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertEquals("Le nombre doit être entre 0 et 100", response.getBody().get("error"));
    }
}