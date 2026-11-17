package com.microsoft.migration.assets.worker.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.test.util.ReflectionTestUtils;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertTrue;

class LocalFileProcessingServiceTest {

    @TempDir
    Path tempDir;

    @Test
    void initCreatesStorageDirectory() throws Exception {
        Path storage = tempDir.resolve("nested").resolve("storage");
        LocalFileProcessingService service = new LocalFileProcessingService();
        ReflectionTestUtils.setField(service, "storageDirectory", storage.toString());

        service.init();

        assertTrue(Files.isDirectory(storage));
    }

    @Test
    void postConstructUsesJakartaAnnotation() throws Exception {
        assertTrue(LocalFileProcessingService.class.getMethod("init")
                .isAnnotationPresent(jakarta.annotation.PostConstruct.class));
    }
}
