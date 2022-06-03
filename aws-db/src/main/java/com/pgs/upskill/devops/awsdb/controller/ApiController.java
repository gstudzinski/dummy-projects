package com.pgs.upskill.devops.awsdb.controller;


import com.pgs.upskill.devops.awsdb.model.User;
import com.pgs.upskill.devops.awsdb.repo.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@AllArgsConstructor
@RestController
@RequestMapping("/api")
public class ApiController {

    UserRepository userRepository;

    @GetMapping("/users")
    Iterable<User> all() {
        return userRepository.findAll();
    }

    @GetMapping("/users/count")
    long count() {
        return userRepository.count();
    }

}
