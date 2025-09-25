package com.kata.foobarquix.controller;

import com.kata.foobarquix.service.NumberTransformationService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(NumberTransformationController.class)
class NumberTransformationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private NumberTransformationService transformationService;

    @Test
    void testTransformNumber_ValidNumber_ShouldReturnOk() throws Exception {
        // Given
        when(transformationService.transform(15)).thenReturn("FOOBARBAR");

        // When & Then
        mockMvc.perform(get("/api/transform/15"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.input").value(15))
                .andExpect(jsonPath("$.result").value("FOOBARBAR"));
    }

    @Test
    void testTransformNumber_InvalidNumber_ShouldReturnBadRequest() throws Exception {
        // Given
        when(transformationService.transform(101)).thenThrow(new IllegalArgumentException("Le nombre doit être entre 0 et 100"));

        // When & Then
        mockMvc.perform(get("/api/transform/101"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Le nombre doit être entre 0 et 100"));
    }
}