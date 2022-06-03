package com.pgs.upskill.devops.awsdb.controller;

import com.pgs.upskill.devops.awsdb.model.User;
import com.pgs.upskill.devops.awsdb.repo.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@AllArgsConstructor
public class AppController {

    UserRepository userRepository;

    @ModelAttribute("allUsers")
    public Iterable<User> populateUsers() {
        return userRepository.findAll();
    }

    @RequestMapping({"/","/index"})
    public String content() {
        return "content";
    }

}
