package com.pgs.upskill.devops.awsdb.repo;

import com.pgs.upskill.devops.awsdb.model.User;
import org.springframework.stereotype.Repository;

import org.springframework.data.repository.CrudRepository;

@Repository
public interface UserRepository extends CrudRepository<User, Integer>  {
}
