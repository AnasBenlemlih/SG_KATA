package com.kata.foobarquix;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(properties = {
    "spring.batch.job.enabled=false"
})
class FooBarQuixApplicationTest {

    @Test
    void contextLoads() {
        // Test que l'application Spring Boot se charge correctement
    }
}