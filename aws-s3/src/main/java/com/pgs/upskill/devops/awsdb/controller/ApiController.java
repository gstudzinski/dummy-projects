package com.pgs.upskill.devops.awsdb.controller;


import com.pgs.upskill.devops.awsdb.service.S3UrlService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@AllArgsConstructor
@RestController
@RequestMapping("/api")
public class ApiController {

    S3UrlService s3UrlService;

    @GetMapping("/health")
    String health() {
        return "OK";
    }

    @GetMapping("/s3-url")
    String s3PresignedUrl(@RequestParam String fileName, @RequestParam String type) {
        return s3UrlService.generatePresignedUrl(fileName, type);
    }



}
