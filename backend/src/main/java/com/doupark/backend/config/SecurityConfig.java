package com.doupark.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;

import java.util.List;

@Configuration
public class SecurityConfig {

    private final JwtFilter jwtFilter;

    public SecurityConfig(JwtFilter jwtFilter) {
        this.jwtFilter = jwtFilter;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 1. CORS Ayarlarını Doğrudan Security'ye Ekliyoruz
            .cors(cors -> cors.configurationSource(request -> {
                CorsConfiguration config = new CorsConfiguration();
                config.setAllowedOrigins(List.of("*"));
                config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
                config.setAllowedHeaders(List.of("*"));
                return config;
            }))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // KRİTİK NOKTA 1: Tarayıcının token'sız gönderdiği OPTIONS isteklerine izin ver
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll() 
                
                .requestMatchers("/api/auth/**").permitAll()  // login/register açık
                
                // KRİTİK NOKTA 2: Otopark verilerini listelemek için token zorunluluğunu şimdilik kaldırıyoruz
                // (Eğer Flutter tarafında henüz Token göndermiyorsan bu sayede verileri görebilirsin)
                .requestMatchers("/api/parking/**").permitAll() 
                .requestMatchers("/api/parkings/**").permitAll() // URL hangisiyse garanti olsun diye ikisini de ekledim
                
                .anyRequest().authenticated()                 // geri kalanı JWT ister
            )
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}