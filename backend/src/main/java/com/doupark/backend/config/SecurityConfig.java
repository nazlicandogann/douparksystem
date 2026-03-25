package com.doupark.backend.config;

import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import com.doupark.backend.config.JwtFilter;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.http.SessionCreationPolicy;

@Configuration
public class SecurityConfig {
    private final JwtFilter jwtFilter;

public SecurityConfig(JwtFilter jwtFilter) {
    this.jwtFilter = jwtFilter;
}

@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

    http
        .csrf(csrf -> csrf.disable())

        .headers(headers -> headers
            .frameOptions(frame -> frame.disable())
        )

        .sessionManagement(session ->
            session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
        )

        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/auth/**").permitAll()
            .requestMatchers("/h2-console/**").permitAll()
            .anyRequest().authenticated()
        )

        .httpBasic(httpBasic -> httpBasic.disable())
        .formLogin(form -> form.disable())

        // 🔥 EN KRİTİK SATIR
        .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

    return http.build();
}
}