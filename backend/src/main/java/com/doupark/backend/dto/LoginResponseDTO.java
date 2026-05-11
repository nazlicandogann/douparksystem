package com.doupark.backend.dto;

public class LoginResponseDTO {

    private String token;
    private String refreshToken;
    private String email;
    private String name;
    private String role;

    public LoginResponseDTO(String token, String refreshToken, String email, String name, String role) {
        this.token = token;
        this.refreshToken = refreshToken;
        this.email = email;
        this.name = name;
        this.role = role;
    }

    public String getToken() { return token; }
    public String getRefreshToken() { return refreshToken; }
    public String getEmail() { return email; }
    public String getName() { return name; }
    public String getRole() { return role; }
}