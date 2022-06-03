package com.pgs.upskill.devops.awsdb.service;

import com.pgs.upskill.devops.awsdb.properties.DBAppProperties;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class UserDBService {
    DBAppProperties dbAppProperties;
    RestTemplate restTemplate;

    public UserDBService(DBAppProperties dbAppProperties) {
        this.dbAppProperties = dbAppProperties;
        restTemplate = new RestTemplate();
    }


    public Integer getUserCount() {
        String url = dbAppProperties.getUrl() + "/api/users/count";
        String countStr = restTemplate.getForObject(url, String.class);
        return Integer.valueOf(countStr);
    }


}
