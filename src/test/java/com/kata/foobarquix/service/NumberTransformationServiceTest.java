package com.kata.foobarquix.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class NumberTransformationServiceTest {

    private NumberTransformationService transformationService;

    @BeforeEach
    void setUp() {
        transformationService = new NumberTransformationService();
    }

    @Test
    void testTransform_ExamplesFromSpecification() {
        // Test des exemples donnés dans l'énoncé
        assertEquals("1", transformationService.transform(1));
        assertEquals("FOOFOO", transformationService.transform(3));
        assertEquals("BARBAR", transformationService.transform(5));
        assertEquals("QUIX", transformationService.transform(7));
        assertEquals("FOO", transformationService.transform(9));
        assertEquals("FOOBAR", transformationService.transform(51));
        assertEquals("BARFOO", transformationService.transform(53));
        assertEquals("FOOFOOFOO", transformationService.transform(33));
        assertEquals("FOOBARBAR", transformationService.transform(15));
    }

    @Test
    void testTransform_DivisibilityRules() {
        assertEquals("FOO", transformationService.transform(6));   // divisible par 3
        assertEquals("BAR", transformationService.transform(10));  // divisible par 5
        assertEquals("FOOBARBAR", transformationService.transform(15)); // divisible par 3 ET 5
    }

    @Test
    void testTransform_ContentRules() {
        assertEquals("FOO", transformationService.transform(13));  // contient 3
        assertEquals("BARBAR", transformationService.transform(25));  // divisible par 5 + contient 5
        assertEquals("QUIX", transformationService.transform(17)); // contient 7
    }

    @Test
    void testTransform_CombinedRules() {
        // 15 : divisible par 3 (FOO) + divisible par 5 (BAR) + contient 5 (BAR)
        assertEquals("FOOBARBAR", transformationService.transform(15));
        
        // 33 : divisible par 3 (FOO) + contient 3 (FOO) + contient 3 (FOO)
        assertEquals("FOOFOOFOO", transformationService.transform(33));
    }

    @Test
    void testTransform_InvalidNumbers() {
        assertThrows(IllegalArgumentException.class, () -> transformationService.transform(-1));
        assertThrows(IllegalArgumentException.class, () -> transformationService.transform(101));
    }

    @Test
    void testTransform_EdgeCases() {
        assertEquals("FOOBAR", transformationService.transform(0));     // minimum, divisible par 3 et 5
        assertEquals("BAR", transformationService.transform(100)); // maximum, divisible par 5
        assertEquals("2", transformationService.transform(2));     // aucun chiffre spécial
    }
}