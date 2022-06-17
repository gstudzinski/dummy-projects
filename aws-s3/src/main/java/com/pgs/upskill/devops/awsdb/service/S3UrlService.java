package com.pgs.upskill.devops.awsdb.service;

import com.pgs.upskill.devops.awsdb.properties.S3Properties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.auth.credentials.EnvironmentVariableCredentialsProvider;
import software.amazon.awssdk.auth.credentials.InstanceProfileCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

import java.time.Duration;

@Slf4j
@Service
public class S3UrlService {
    S3Properties properties;
    S3Presigner s3Presigner;

    public S3UrlService(S3Properties properties) {
        this.properties = properties;
        Region region = Region.of(properties.getRegion());
        var credentialProvider = properties.isAccessByProfile()
                ? null
                : EnvironmentVariableCredentialsProvider.create();
        s3Presigner = S3Presigner.builder()
                .region(region)
                .credentialsProvider(credentialProvider)
                .build();
    }

    public String generatePresignedUrl(String fileName, String type) {
        try {
            PutObjectRequest objectRequest = PutObjectRequest.builder()
                    .bucket(properties.getBucket())
                    .key(fileName)
                    .contentType(type)
                    .build();

            PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                    .signatureDuration(Duration.ofMinutes(10))
                    .putObjectRequest(objectRequest)
                    .build();

            PresignedPutObjectRequest presignedRequest = s3Presigner.presignPutObject(presignRequest);
            String signedURL = presignedRequest.url().toString();
            log.info("Presigned URL to upload a file to: " + signedURL);

            return signedURL;
        } catch (Exception e) {
            log.error("Error on S3 url generation", e);
            throw new RuntimeException(e);
        }
    }

}
