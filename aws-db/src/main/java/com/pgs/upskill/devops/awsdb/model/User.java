package com.pgs.upskill.devops.awsdb.model;


import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;


import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name="users")
@Getter
@Setter
public class User {
    @Id
    Integer id;
    String name;
}
