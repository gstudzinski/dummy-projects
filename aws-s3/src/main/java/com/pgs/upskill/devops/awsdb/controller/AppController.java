package com.pgs.upskill.devops.awsdb.controller;

import com.pgs.upskill.devops.awsdb.service.UserDBService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@AllArgsConstructor
public class AppController {

    UserDBService userService;

    @ModelAttribute("usersCount")
    public Integer usersCount() {
        return userService.getUserCount();
    }

    @RequestMapping({"/","/index.html"})
    public String content() {
        return "content";
    }

}
