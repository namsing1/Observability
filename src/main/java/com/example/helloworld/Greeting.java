package com.example.helloworld;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Greeting {
	
	private static final Logger LOGGER = LoggerFactory.getLogger(Greeting.class);
	
	@GetMapping(path = "/greet")
	public String greetWorld() {
		
		LOGGER.info("Greeting from GCP!");
		
		return "Hello World";
		
	}

}
