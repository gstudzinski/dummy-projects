package com.pgs.upskill.devops.awsdb.properties;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.regions.Region;

@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "s3")
public class S3Properties {
    private String bucket;
    private String region;
}
