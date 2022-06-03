package com.pgs.upskill.devops.awsdb.controller;

import com.pgs.upskill.devops.awsdb.service.S3UrlService;
import com.pgs.upskill.devops.awsdb.service.UserDBService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Map;

@Controller
@AllArgsConstructor
public class AppController {

    UserDBService userService;

    @ModelAttribute("usersCount")
    public Integer usersCount() {
        return userService.getUserCount();
    }

    @RequestMapping({"/","/index"})
    public String content() {
        return "content";
    }

}
