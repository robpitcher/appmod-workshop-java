package com.microsoft.migration.assets.worker.config;

import com.microsoft.migration.assets.worker.model.ImageProcessingMessage;
import org.junit.jupiter.api.Test;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageProperties;
import org.springframework.amqp.support.converter.JacksonJsonMessageConverter;

import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertEquals;

class MessageContractTest {

    private final JacksonJsonMessageConverter converter = new JacksonJsonMessageConverter();

    @Test
    void consumesJsonProducedByWebModule() {
        MessageProperties props = new MessageProperties();
        props.setContentType(MessageProperties.CONTENT_TYPE_JSON);
        props.setInferredArgumentType(ImageProcessingMessage.class);
        String json = "{\"key\":\"a.jpg\",\"contentType\":\"image/jpeg\",\"storageType\":\"local\",\"size\":42}";

        ImageProcessingMessage msg = (ImageProcessingMessage) converter.fromMessage(
                new Message(json.getBytes(StandardCharsets.UTF_8), props));

        assertEquals(new ImageProcessingMessage("a.jpg", "image/jpeg", "local", 42L), msg);
    }
}
