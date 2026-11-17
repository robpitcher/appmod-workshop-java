package com.microsoft.migration.assets.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.test.util.ReflectionTestUtils;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;

class LocalFileStorageServiceTest {

    @TempDir
    Path tempDir;

    @Test
    void initCreatesStorageDirectory() throws Exception {
        Path storage = tempDir.resolve("nested").resolve("storage");
        LocalFileStorageService service = new LocalFileStorageService(mock(RabbitTemplate.class));
        ReflectionTestUtils.setField(service, "storageDirectory", storage.toString());

        service.init();

        assertTrue(Files.isDirectory(storage));
    }

    @Test
    void postConstructUsesJakartaAnnotation() throws Exception {
        assertTrue(LocalFileStorageService.class.getMethod("init")
                .isAnnotationPresent(jakarta.annotation.PostConstruct.class));
    }
}
