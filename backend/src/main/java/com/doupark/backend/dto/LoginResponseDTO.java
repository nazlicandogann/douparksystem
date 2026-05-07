package com.doupark.backend.dto;

public class LoginResponseDTO {

    private String token;
    private String refreshToken;
    private String email;
    private String name;

    public LoginResponseDTO(String token, String refreshToken, String email, String name) {
        this.token = token;
        this.refreshToken = refreshToken;
        this.email = email;
        this.name = name;
    }

    public String getToken() {
        return token;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public String getEmail() {
        return email;
    }

    public String getName() {
        return name;
    }
}