package com.microsoft.migration.assets.config;

import com.microsoft.migration.assets.model.ImageProcessingMessage;
import org.junit.jupiter.api.Test;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageProperties;
import org.springframework.amqp.support.converter.JacksonJsonMessageConverter;

import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertEquals;

class MessageContractTest {

    private final JacksonJsonMessageConverter converter = new JacksonJsonMessageConverter();

    @Test
    void producesJsonFieldContractConsumedByWorker() {
        Message message = converter.toMessage(
                new ImageProcessingMessage("a.jpg", "image/jpeg", "local", 42L), new MessageProperties());

        String json = new String(message.getBody(), StandardCharsets.UTF_8);
        assertEquals("{\"key\":\"a.jpg\",\"contentType\":\"image/jpeg\",\"storageType\":\"local\",\"size\":42}", json);
    }
}
