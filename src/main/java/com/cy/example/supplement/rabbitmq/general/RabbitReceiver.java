package com.cy.example.supplement.rabbitmq.general;

import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import com.cy.example.entity.UserEntity;

@Component
@RabbitListener(queues = "user")
public class RabbitReceiver {

    @RabbitHandler
    public void process(UserEntity user) {
        System.out.println("Receiver object : " + user);
    }

}
