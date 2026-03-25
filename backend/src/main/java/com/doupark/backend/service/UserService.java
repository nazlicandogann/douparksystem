package com.doupark.backend.service;

import com.doupark.backend.entity.User;
import com.doupark.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User register(User user){
        return userRepository.save(user);
    }
    public User login(String email, String password){

    User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));

    if(!user.getPassword().equals(password)){
        throw new RuntimeException("Wrong password");
    }

    return user;
}
}